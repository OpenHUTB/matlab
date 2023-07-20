



classdef SignalSpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
        mChannel=[];
        mSelectionName=[];
        mSelectionHandle=[];
        mSelectedViewerOrGen=[];
    end

    properties(Access=private,Constant=false)


        displayColumn=getString(message('Spcuilib:scopes:SSMgrDisplay'));
        nameColumn=getString(message('Spcuilib:scopes:SSMgrName'));
    end

    methods
        function this=SignalSpreadsheetRow(channel,selName,selHdl,selectedViewerOrGen)
            this.mChannel=channel;
            this.mSelectionName=selName;
            if(nargin>2)
                this.mSelectionHandle=selHdl;
            end
            if(nargin>3)
                this.mSelectedViewerOrGen=selectedViewerOrGen;
            end
        end


        function[aLabel]=getDisplayLabel(this)
            aLabel=this.mSelectionName;
        end


        function[aIcon]=getDisplayIcon(this)
            aIcon='';
        end



        function[bIsValid]=isValidProperty(~,~)
            bIsValid=true;
        end

        function[isReadOnly]=isReadonlyProperty(this,aPropName)
            try
                switch(aPropName)
                case{this.displayColumn}
                    isReadOnly=true;
                    if isempty(this.mSelectedViewerOrGen)||~ishandle(this.mSelectedViewerOrGen)
                        return;
                    end
                    numAxes=sigandscopemgr('GetNumPorts',this.mSelectedViewerOrGen);

                    viewerMask=Simulink.Mask.get(this.mSelectedViewerOrGen);
                    isMPlay=~isempty(viewerMask)&&contains(viewerMask.Type,'MPlay');

                    if numAxes>1&&~isMPlay
                        isReadOnly=false;
                    end
                otherwise
                    isReadOnly=true;
                end
            catch ME
                this.reportError(ME);
            end
        end


        function[aPropValue]=getPropValue(this,aPropName)
            switch(aPropName)
            case{this.nameColumn}
                aPropValue=this.mSelectionName;
            case{this.displayColumn}
                aPropValue=num2str(this.mChannel);
            otherwise
                aPropValue={};
            end
        end



        function[aStyle]=getPropertyStyle(this,aPropName)
            aStyle=DAStudio.PropertyStyle;




            aStyle.ForegroundColor=[0,0,0];
        end


        function aPropType=getPropDataType(this,aPropName)
            switch(aPropName)
            case{this.displayColumn}
                aPropType='enum';
            otherwise
                aPropType='string';
            end
        end

        function propValues=getPropAllowedValues(this,aPropName)
            try
                switch(aPropName)
                case this.displayColumn
                    numAxes=sigandscopemgr('GetNumPorts',this.mSelectedViewerOrGen);
                    propValues=arrayfun(@(x){num2str(x)},1:numAxes);
                otherwise
                    propValues={};
                end
            catch ME
                this.reportError(ME);
            end
        end




        function isHyperlink=propertyHyperlink(this,aPropName,clicked)
            isHyperlink=false;
        end

        function setPropValue(this,aPropName,aPropValue)
            try
                switch(aPropName)
                case{this.displayColumn}
                    if strcmpi(this.mSelectionName,DAStudio.message('Simulink:blocks:SSMgrNoSelection'))||...
                        isempty(this.mSelectionHandle)
                        return;
                    end
                    slsignalselector.utils.SignalSelectorUtilities.switchInputOrDisplaySelection(this.mSelectedViewerOrGen,this.mSelectionHandle,this.mChannel,str2num(aPropValue));
                    this.mChannel=aPropValue;
                    aDlgs=DAStudio.ToolRoot.getOpenDialogs;
                    if~isempty(aDlgs)
                        for i=1:numel(aDlgs)
                            if strfind(aDlgs(i).dialogTag,'SSMgr')
                                ss=aDlgs(i).getWidgetInterface('ssMgrSignalSpreadsheet');
                                if~isempty(ss)
                                    ss.update;
                                end
                            end
                        end
                    end








                otherwise

                end
            catch me
                this.reportError(me);
            end
        end
    end


    methods(Access=public,Hidden)
        function setDisplayColumn(this,newColumnName)
            this.displayColumn=newColumnName;
        end

        function setTypeColumn(this,newColumnName)
            this.nameColumn=newColumnName;
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
            scope=strcmp(btype,'Scope');
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



