classdef SignalSelectorController<handle








    methods(Access=private)
        function obj=SignalSelectorController
        end
    end

    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)
                localObj=Simulink.scopes.source.SignalSelectorController;
            end
            singleObj=localObj;
        end
    end

    properties(SetAccess=private)
        Model=[];
        Block=[];


        bindModeSourceDataObj=[];
    end

    methods(Static)
        function turnButtonStateOff(block)
            hScopeSpec=get_param(block,'ScopeSpecificationObject');
            [launched,hScope]=isLaunched(hScopeSpec);
            if launched
                controls=hScope.DataSource.Controls;
                updateSelectionSplit(controls);
                configureSelector(controls);
            end
        end

        function newState=toggle(playbackControls)


            import Simulink.scopes.source.*;


            scopeBlock=playbackControls.Source.BlockHandle;

            this=Simulink.scopes.source.SignalSelectorController.getInstance;
            ud=this.bindModeSourceDataObj;




            if~isempty(ud)
                if ud.isvalid()


                    if(ud.sourceElementHandle~=scopeBlock.Handle)





                        bindModeSource=bdroot(scopeBlock.Handle);

                        bindModeSource=getTopLevelMdl(this.Block);

                        BindMode.BindMode.disableBindMode(get_param(bindModeSource,'Object'));

                        SignalSelectorController.CreateSignalSelector(scopeBlock);
                        newState=true;

                        return;
                    end
                else


                    newState=true;
                    SignalSelectorController.CreateSignalSelector(scopeBlock);
                    return;
                end
                SignalSelectorController.close;
                newState=false;
            else
                newState=true;
                SignalSelectorController.CreateSignalSelector(scopeBlock);
            end
        end

        function close
            this=Simulink.scopes.source.SignalSelectorController.getInstance;



            bindModeSource=bdroot(this.bindModeSourceDataObj.sourceElementHandle);


            bindModeSource=getTopLevelMdl(this.Block);

            modelObj=get_param(bindModeSource,'Object');
            BindMode.BindMode.disableBindMode(modelObj)
            this.bindModeSourceDataObj=[];

        end

        function enable(scopeBlock,~)



            this=Simulink.scopes.source.SignalSelectorController.getInstance;
            ud=this.bindModeSourceDataObj;

            if~isempty(ud)&&ud.isvalid()
                if ud.sourceElementHandle==scopeBlock.Handle
                    this.Block=scopeBlock.Handle;
                    this.Model=bdroot(this.Block);
                end
            end
        end

        function selectDisplay(blockHandle,inputNumber)









            import Simulink.scopes.source.*;





            if inputNumber~=0
                SignalSelectorController.unselectAllLines(bdroot(blockHandle));
                SignalSelectorController.selectLines(blockHandle)
            end
        end

        function selectLines(block,varargin)



            hLines=Simulink.scopes.ViewerUtil.GetPortsAndLinesConnectedToViewer(block,varargin{:});




            for indx=1:numel(hLines)
                set_param(hLines(indx),'Selected','on');
            end
        end

        function unselectAllLines(bd,hBlock)





            hLines=find_system(bd,'findall','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'type','line','selected','on');
            if nargin>1
                hLinesToLeaveOn=...
                Simulink.scopes.ViewerUtil.GetPortsAndLinesConnectedToViewer(hBlock);
                hLines=getLineRoot(hLines);
                hLinesToLeaveOn=getLineRoot(hLinesToLeaveOn);
                hLines=setdiff(hLines,hLinesToLeaveOn);
            end
            arrayfun(@(x)set_param(x,'selected','off'),hLines);
        end

        function varargout=Util(varargin)



            Action=varargin{1};
            args=varargin(2:end);


            this=Simulink.scopes.source.SignalSelectorController.getInstance;

            switch Action

            case 'GetSelection'
                hBlock=args{1};
                AxesNumber=args{2};

                selection=sigandscopemgr(Action,hBlock,AxesNumber);
                varargout{1}=selection;

            case 'AddSelection'
                hBlock=args{1};
                AxesNumber=args{2};
                addSelHandle=args{3};

                Simulink.scopes.Util.AddSelection(hBlock,AxesNumber,addSelHandle);

            case 'RemoveSelection'
                hBlock=args{1};
                AxesNumber=args{2};
                remSelHandle=args{3};




                Simulink.scopes.Util.RemoveSelection(hBlock,AxesNumber,remSelHandle);

            case 'DialogClosing'


                hBlock=args{1};
                this.Model=[];
                this.Block=[];
                this.turnButtonStateOff(hBlock);
                this.unselectAllLines(bdroot(hBlock));

            otherwise




            end
        end

        function out=getSelectedDisplay(varargin)






            out=0;

            hBlock=varargin{2};

            hScopeSpec=get_param(hBlock,'ScopeSpecificationObject');
            if isempty(hScopeSpec)
                return;
            end
            [launched,hScope]=isLaunched(hScopeSpec);

            if launched&&strcmp(hScope.DataSource.ConnectionMode,'floating')
                hScopeCfg=get_param(hBlock,'ScopeConfiguration');
                out=hScopeCfg.ActiveDisplay;
            end
        end

        function CreateSignalSelector(scopeBlock)




            numPorts=Simulink.scopes.ViewerUtil.getNumAxes(scopeBlock.handle);

            this=Simulink.scopes.source.SignalSelectorController.getInstance;
            this.Block=scopeBlock.handle;




            this.Model=getTopLevelMdl(this.Block);
            this.bindModeSourceDataObj=BindMode.SignalSelectorSourceData(this.Model,scopeBlock.getFullName,...
            true,numPorts,isFloating(scopeBlock),getString(message('Spcuilib:scopes:BindToDisplayType')));
            BindMode.BindMode.enableBindMode(this.bindModeSourceDataObj);

            studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(scopeBlock.handle));
            if~isempty(studioApp)
                studioApp.getStudio().show;
            end


            isRunning=~strcmp(get_param(bdroot(scopeBlock.handle),'SimulationStatus'),'stopped');
            Simulink.scopes.source.SignalSelectorController.enable(...
            scopeBlock,isRunning);
        end

        function b=isAttached(hBlock)
            this=Simulink.scopes.source.SignalSelectorController.getInstance;
            b=isequal(hBlock,this.Block);
        end

        function b=isAttachedModel(hModel)
            this=Simulink.scopes.source.SignalSelectorController.getInstance;
            b=isequal(this.Model,hModel);
        end
    end
end

function mdl=getTopLevelMdl(blkHandle)






    parent=get_param(blkHandle,'Parent');
    parentHandle=get_param(parent,'Handle');




    studioApp=SLM3I.SLDomain.getLastActiveStudioAppWith(bdroot(parentHandle));
    assert(~isempty(studioApp));
    mdl=get_param(studioApp.blockDiagramHandle,'Name');


end

function b=isFloating(block)

    if strcmp(get(block,'Floating'),'off')
        b=0;
    else
        b=1;
    end

end

function hLines=getLineRoot(hLines)

    for indx=1:numel(hLines)

        lineParent=get(hLines(indx),'LineParent');
        while lineParent~=-1
            hLines(indx)=lineParent;
            lineParent=get(hLines(indx),'LineParent');
        end

    end

end


