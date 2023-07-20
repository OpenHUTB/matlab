function wasSaved=closeReqSet(reqSet,isUI)


    wasSaved=false;

    if nargin<2
        isUI=false;
    end

    if ischar(reqSet)
        reqSetData=slreq.data.ReqData.getInstance.getReqSet(reqSet);
        if isempty(reqSetData)
            error(message('Slvnv:slreq:ArtifactNotLoaded',reqSet));
        end
    elseif isa(reqSet,'slreq.data.RequirementSet')
        reqSetData=reqSet;
    else
        error(message('Slvnv:slreq:InvalidInputArgument'));
    end

    if reqSetData.dirty&&isempty(reqSetData.parent)
        doSave=[];
        if isUI
            response=questdlg(getString(message('Slvnv:slreq:RequirementSetHasChangesToSave',reqSetData.name)),...
            getString(message('Slvnv:slreq:UnsavedRequirementsData')),...
            getString(message('Slvnv:slreq:Save')),...
            getString(message('Slvnv:rmiml:Discard')),...
            getString(message('Slvnv:slreq:Save')));
            if~isempty(response)&&strcmp(response,getString(message('Slvnv:slreq:Save')))
                doSave=true;
            end
        else
            while true
                yn=input(getString(message('Slvnv:slreq:RequirementSetHasUnsavedChangesYN',reqSetData.name)),'s');
                if yn(1)=='y'||yn(1)=='Y'
                    doSave=true;
                    break;
                elseif yn(1)=='n'||yn(1)=='N'
                    doSave=false;
                    break;
                end
            end
        end
        if doSave
            reqSetData.save();
            wasSaved=true;
        end
    end



    possibleLinkSet=slreq.data.ReqData.getInstance.getLinkSet(reqSetData.name,'linktype_rmi_slreq');
    if~isempty(possibleLinkSet)
        possibleLinkSet.discard();
    end


    if isempty(reqSetData.parent)
        reqSetData.discard();
    end
end
