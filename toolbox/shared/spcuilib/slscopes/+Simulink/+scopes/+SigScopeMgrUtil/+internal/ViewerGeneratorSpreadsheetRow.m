




classdef ViewerGeneratorSpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
        mObjectSource=[];
        mSource=[];
        mDlg=[];
    end

    properties(Access=private,Constant=true)


        nameColumn=getString(message('Spcuilib:scopes:SSMgrName'));
        typeColumn=getString(message('Spcuilib:scopes:SSMgrType'));
        numInputsColumn=getString(message('Spcuilib:scopes:SSMgrIn'));
    end

    methods
        function this=ViewerGeneratorSpreadsheetRow(obj,dlg)
            this.mObjectSource=obj;
            this.mSource=obj.getHandle();
            this.mDlg=dlg;
        end


        function[aLabel]=getDisplayLabel(this)
            aLabel=this.getDisplayName();
        end

        function[aIcon]=getDisplayIcon(this)
            suffix='_16.png';
            type=this.getType();
            type=strrep(type,' ','_');

            filename=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','viewer',[type,suffix]);
            if exist(filename,'file')==2
                aIcon=filename;
            else
                defaultType='Scope';
                default=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','viewer',[defaultType,suffix]);
                aIcon=default;
            end
        end



        function[bIsValid]=isValidProperty(~,~)
            bIsValid=true;
        end

        function[isReadOnly]=isReadonlyProperty(this,propName)
            isReadOnly=true;
            if(strcmp(propName,this.nameColumn))
                isReadOnly=false;
            end
        end


        function[aPropValue]=getPropValue(this,aPropName)
            switch(aPropName)
            case{this.nameColumn}
                aPropValue=this.getDisplayName();
            case{this.typeColumn}
                aPropValue=this.getType();
            case{this.numInputsColumn}
                aPropValue=num2str(this.getNumDisplays());
            otherwise
                aPropValue='';
            end
        end



        function[aStyle]=getPropertyStyle(this,aPropName)
            aStyle=DAStudio.PropertyStyle;

























            aStyle.ForegroundColor=[0,0,0];
        end





        function isHyperlink=propertyHyperlink(this,aPropName,clicked)

















            isHyperlink=false;
        end

        function setPropValue(this,aPropName,aPropValue)
            try
                switch(aPropName)
                case{this.nameColumn}






                    set_param(this.mSource,'name',aPropValue);






                    dlgs=DAStudio.ToolRoot.getOpenDialogs(this.mDlg);
                    if this.mObjectSource.isGenerator()
                        spreadSheetIntef=arrayfun(@(x)x.getWidgetInterface('ssMgrGeneratorSpreadsheet'),dlgs);
                    else
                        spreadSheetIntef=arrayfun(@(x)x.getWidgetInterface('ssMgrViewerSpreadsheet'),dlgs);
                    end
                    arrayfun(@(x)x.update(this),spreadSheetIntef);
                otherwise

                end
            catch me
                this.reportError(me);
            end
        end
    end


    methods(Access=private)

        function reportError(~,me)
            dp=DAStudio.DialogProvider;
            title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
            dp.errordlg(me.message,title,true);
        end

        function displayName=getDisplayName(this)
            displayName=strrep(get_param(this.mSource,'Name'),sprintf('\n'),' ');
        end



        function ioType=getType(this)
            ioType='';
            ioTypeObject=this.mObjectSource.getIOType();
            if~isempty(ioTypeObject)
                ioType=ioTypeObject.getName();
            end
        end

        function numPorts=getNumDisplays(this)

            object=this.mSource;

            btype=get_param(object,'BlockType');
            scope=strcmp(btype,'Scope')||strcmp(btype,'WebTimeScopeBlock');
            if scope
                numPorts=Simulink.scopes.ViewerUtil.getNumAxes(object);
            else
                portCounts=get_param(object,'Ports');
                numPorts=0;

                if strcmp(get_param(object,'IOType'),'viewer')
                    isMPlay=~isempty(strfind(get_param(object,'name'),'MPlay'));
                    if isMPlay
                        numPorts=1;
                    else
                        numPorts=portCounts(1);
                    end
                elseif strcmp(get_param(object,'IOType'),'siggen')
                    numPorts=portCounts(2);
                end
            end
        end



        function hiliteBlks(~,modelName,AnnotationString)

            set_param(modelName,'HiliteAncestors','off')
            regExpForAnnotationString=['\<',AnnotationString,'\>'];
            allBlks=find_system(modelName,'regexp','on','MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','VariantAnnotationStringDisplay',regExpForAnnotationString);

            hilite_system_for_annotation(allBlks,modelName,'find');

            function hilite_system_for_annotation(sys,~,hilite,varargin)








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

end



