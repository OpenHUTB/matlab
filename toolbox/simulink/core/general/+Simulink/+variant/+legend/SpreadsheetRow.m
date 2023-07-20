





classdef SpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
m_Name
m_DlgSource

m_annotation
m_VisualCondition
m_CodeCondition
m_ConditionSrc
m_IsStartupCondition
    end

    properties(Access=private,Constant=true)
        nameColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumn');
        ownerColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableOwnerColumn');


        annotationColumn=DAStudio.message('Simulink:utility:AnnotationWithoutColon');
        visualConditionColumn=DAStudio.message('Simulink:utility:VariantConditions');
        codeConditionColumn=DAStudio.message('Simulink:utility:VariantConditionCG');
        conditionSrcColumn=DAStudio.message('Simulink:utility:VariantConditionSRC');
    end

    properties(Access=public,Constant=true)
        protectedLabel=DAStudio.message('Simulink:dialog:ModelRefArgsTableProtectedModel');
    end

    methods
        function obj=SpreadsheetRow(aDlgSource,aname,annotation,condition,codecondition,source,isStartupCondition)

            obj.m_DlgSource=aDlgSource;
            obj.m_annotation=annotation;
            obj.m_VisualCondition=condition;
            obj.m_Name=aname;
            obj.m_CodeCondition=codecondition;
            obj.m_ConditionSrc=source;
            obj.m_IsStartupCondition=isStartupCondition;
        end

        function[aLabel]=getDisplayLabel(this)
            aLabel=this.m_Name;
        end

        function[aIcon]=getDisplayIcon(~)
            aIcon='';
        end


        function[bIsValid]=isValidProperty(~,~)
            bIsValid=true;
        end


        function[bIsReadOnly]=isReadonlyProperty(~,~)
            bIsReadOnly=true;
        end


        function[aPropValue]=getPropValue(this,aPropName)
            switch(aPropName)
            case this.nameColumn
                aPropValue=this.m_Name;
            case this.annotationColumn
                aPropValue=this.m_annotation;
            case this.visualConditionColumn
                aPropValue=this.m_VisualCondition;
            case this.codeConditionColumn
                if isempty(this.m_CodeCondition)
                    aPropValue='unconditional';
                else
                    aPropValue=this.m_CodeCondition;
                end
            case this.conditionSrcColumn
                if(strcmp(this.m_ConditionSrc,'Global'))
                    aPropValue=DAStudio.message('Simulink:utility:VariantCondWksGlobal');
                elseif(strcmp(this.m_ConditionSrc,'Model'))
                    aPropValue=DAStudio.message('Simulink:utility:VariantCondWksModel');
                elseif(strcmp(this.m_ConditionSrc,'--'))
                    aPropValue='--';
                else
                    aPropValue=DAStudio.message('Simulink:utility:VariantCondWksMask');
                end
            otherwise
                aPropValue='';
            end
        end



        function getPropertyStyle(this,aPropName,aStyle)



            aStyle.ForegroundColor=[0,0,0];

            switch(aPropName)
            case this.visualConditionColumn
                if strcmp(this.m_VisualCondition,'_0empty')
                    aStyle.Tooltip='unconditional';
                else
                    aStyle.Tooltip=this.m_VisualCondition;
                end
            case this.codeConditionColumn
                if(~isempty(this.m_CodeCondition))
                    aStyle.Italic=false;

                    aStyle.ForegroundColor=[0.5,0.5,0.5];
                    aStyle.Tooltip=this.m_CodeCondition;

                    if this.m_IsStartupCondition
                        aStyle.Italic=true;
                    end
                else



                    aStyle.Tooltip='unconditional';
                    aStyle.Italic=true;
                end
            case this.conditionSrcColumn
                if(~isempty(this.m_ConditionSrc))
                    if(strcmp(this.m_ConditionSrc,'Global')||...
                        strcmp(this.m_ConditionSrc,'Model'))
                        aStyle.Tooltip=this.m_Name;
                    else
                        aStyle.Tooltip=this.m_ConditionSrc;
                    end
                end
            end

        end





        function isHyperlink=propertyHyperlink(this,aPropName,clicked)

            switch(aPropName)

            case this.annotationColumn
                if strcmp(this.m_VisualCondition,'--')
                    isHyperlink=false;
                else
                    isHyperlink=true;
                    if clicked
                        this.hiliteBlks(this.m_Name,this.m_annotation);
                    end
                end
            case this.conditionSrcColumn
                if strcmp(this.m_ConditionSrc,'--')
                    isHyperlink=false;
                else
                    isHyperlink=true;
                    if clicked
                        this.hiliteSrcBlk(this.m_Name,this.m_ConditionSrc);
                    end
                end
            otherwise

                isHyperlink=false;
            end


        end
    end


    methods(Access=private)
        function hiliteSrcBlk(this,modelName,blkPath)
            set_param(modelName,'HiliteAncestors','off')
            this.hilite_system_for_annotation({blkPath},modelName,'default');
        end


        function hiliteBlks(this,modelName,AnnotationString)

            set_param(modelName,'HiliteAncestors','off')
            regExpForAnnotationString=['\<',AnnotationString,'\>'];
            allBlks=find_system(modelName,'regexp','on',...
            'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all',...
            'VariantAnnotationStringDisplay',regExpForAnnotationString);

            this.hilite_system_for_annotation(allBlks,modelName,'find');
        end
        function hilite_system_for_annotation(~,sys,~,hilite,varargin)








            if iscell(sys)&&(length(sys)==1)
                sys={cell2mat(sys(1)),cell2mat(sys(1))};
            end





            sys=get_param(sys,'Handle');
            sys=[sys{:}];




            parents=get_param(sys,'Parent');




            mdls=find(strcmp(parents,''));
            parents(mdls)=[];
            sys(mdls)=[];


            numParents=length(parents);
            for pIdx=numParents:-1:1
                parent=parents{pIdx};
                isClosing=slInternal('isBDClosing',bdroot(parent));
                if isClosing
                    parents(pIdx)=[];
                    sys(pIdx)=[];
                end
            end




            if nargin==1
                hilite='on';
            end

            hiliteArgs={'HiliteAncestors',hilite};




            for i=1:length(sys)
                set_param(sys(i),hiliteArgs{:},varargin{:});
            end



            Simulink.scrollToVisible(sys,'ensureFit','off','panMode','minimal');
        end
    end

end




