function[objH,isErrorOrWarning]=canlink(obj,doError)










    isErrorOrWarning=0;
    if nargin==1
        doError=true;
    end

    if ischar(obj)||length(obj)==1

        if isa(obj,'Simulink.DDEAdapter')||isa(obj,'slreq.data.Requirement')
            objH=obj;
            return;
        end


        [modelH,objH,isSf]=rmisl.resolveObj(obj);


        if rmisl.inLibrary(objH,isSf)||rmisl.inSubsystemReference(objH,isSf)
            if doError
                isErrorOrWarning=2;
                errordlg(...
                getString(message('Slvnv:rmi:canlink:CannotEditInLibrary')),...
                getString(message('Slvnv:rmi:canlink:RequirementsLibraryLink')));
            else
                isErrorOrWarning=1;
                warndlg(...
                getString(message('Slvnv:rmi:canlink:CannotEditInLibrary')),...
                getString(message('Slvnv:rmi:canlink:RequirementsLibraryLink')));
            end
            objH=[];
            return;
        end


        if strcmp(get_param(modelH,'BlockDiagramType'),'library')...
            &&slreq.utils.isUsingEmbeddedLinkSet(modelH)...
            &&strcmp(get_param(modelH,'lock'),'on')...
            &&~Simulink.harness.internal.hasActiveHarness(modelH)
            if doError
                isErrorOrWarning=2;
                errordlg(...
                getString(message('Slvnv:rmi:canlink:CannotEditLockedLibrary')),...
                getString(message('Slvnv:rmi:canlink:RequirementsLockedLibrary')));
            else
                isErrorOrWarning=1;
                warndlg(...
                getString(message('Slvnv:rmi:canlink:CannotEditLockedLibrary')),...
                getString(message('Slvnv:rmi:canlink:RequirementsLockedLibrary')));
            end
            objH=[];
            return;
        end


        if isSf&&sf('get',objH,'.isa')==sf('get','default','chart.isa')
            objH=sfChartToSlBlock(objH);
        end


        if~rmidata.isExternal(modelH)
            GUID=rmi('guidget',objH);
            if isempty(GUID)
                objH=[];
            end
        end

    else

        objH=[];
        for i=1:length(obj)
            objH=[objH,rmi.canlink(obj(i),doError)];%#ok<AGROW>
        end
    end

end

function rmiObj=sfChartToSlBlock(sfID)
    sfr=sfroot;
    sfObj=sfr.idToHandle(sfID);
    if any(strcmp(class(sfObj),...
        {'Stateflow.Chart','Stateflow.EMChart',...
        'Stateflow.TruthTableChart','Stateflow.StateTransitionTableChart',...
        'Stateflow.ReactiveTestingTableChart'}))
        rmiObj=sf('Private','chart2block',sfID);
    else
        rmiObj=sfID;
    end
end


