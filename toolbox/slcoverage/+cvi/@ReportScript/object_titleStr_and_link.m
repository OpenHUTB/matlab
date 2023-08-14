function titleStr=object_titleStr_and_link(idPos,addtxt,commandType,isLinked)






    try
        if nargin<2
            addtxt=[];
        end
        if nargin<3
            commandType=0;
        end
        if nargin<4
            isLinked=true;
        end


        if~isempty(addtxt)
            titleStr=cvi.ReportUtils.obj_diag_named_link(idPos,addtxt,commandType,isLinked);
            return;
        end

        id=idPos(1);
        [org,type]=cv('get',id,'.origin','.refClass');
        name=cvi.TopModelCov.getNameFromCvId(id);
        switch org
        case 0
            titleStr=name;
        case 1
            blkTypeId=cv('get',id,'.slBlckType');
            if(blkTypeId==0)
                if type==-99
                    sfClass=cvprivate('get_sf_class',type,id);
                    titleStr=sprintf('%s "%s"',sfClass,cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked));
                elseif(cv('get',id,'.treeNode.parent')==0&&strcmp(name,SlCov.CoverageAPI.getModelcovName(cv('get',id,'.modelcov'))))
                    titleStr=sprintf('%s "%s"',getString(message('Slvnv:simcoverage:cvhtml:Model')),name);
                else
                    handle=cv('get',id,'.handle');
                    if handle==0
                        blckType=[];
                    else
                        blckType=get_param(handle,'BlockType');
                    end
                    titleStr=sprintf('%s %s "%s"',blckType,getString(message('Slvnv:simcoverage:cvhtml:block')),cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked));
                end
            else
                blkType=cv('get',blkTypeId,'.type');
                titleStr=sprintf('%s %s "%s"',blkType,getString(message('Slvnv:simcoverage:cvhtml:block')),cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked));
            end
        case 2
            sfClass=cvprivate('get_sf_class',type,id);

            sfId=cv('get',id,'.handle');
            if strcmp(sfClass,'Transition')
                if isempty(sf('get',sfId,'.src','.dst'))
                    titleStr=[];
                    return;
                end


                [isReqTable,titleStr]=cvi.ReportScript.getDescriptionStrAndLinkIfReqTable(sfId);
                if isReqTable
                    return;
                end

                [srcSfId,destSfId]=sf('get',sfId,'.src.id','.dst.id');


                if(sf('get',sfId,'.autogen.isAutoCreated')&&...
                    sf('get',destSfId,'.isa')==sf('get','default','junction.isa'))
                    autogenSourceId=sf('get',sfId,'.autogen.source');
                    if(Stateflow.STT.StateEventTableMan.isStateTransitionTable(autogenSourceId))
                        destSfId=Stateflow.STT.StateDiagramAutoGenerator.findDestinationStatesOfJunction(destSfId);
                        destSfId=destSfId(1);
                    end
                end


                if(srcSfId==0)
                    titleStr=getString(message('Slvnv:simcoverage:cvhtml:TransitionTo',...
                    cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked),...
                    sf_obj_link(id,destSfId,commandType,isLinked)));
                else

                    titleStr=getString(message('Slvnv:simcoverage:cvhtml:TransitionFromTo',...
                    cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked),...
                    sf_obj_link(id,srcSfId,commandType,isLinked),...
                    sf_obj_link(id,destSfId,commandType,isLinked)));
                end
            else
                if strcmp(sfClass,'State')&&...
                    sf('get',sfId,'state.simulink.isComponent')&&...
                    Sldv.utils.isAtomicSubchartSubsystem(sf('get',sfId,'state.simulink.blockHandle'))
                    sfClass=getString(message('Slvnv:simcoverage:cvhtml:AtomicSubchart'));
                end

                titleStr=sprintf('%s "%s"',sfClass,cvi.ReportUtils.obj_diag_named_link(idPos,addtxt,commandType,isLinked));
            end

        case 3

            if cv('get',id,'.treeNode.parent')==0
                title=getString(message('Slvnv:simcoverage:cvhtml:MATLABFunctionFile'));
            else
                title=getString(message('Slvnv:simcoverage:cvhtml:MATLABFunction'));
            end
            titleStr=sprintf('%s "%s"',title,cvi.ReportUtils.obj_diag_named_link(id,[],commandType,isLinked));

        otherwise
            error(message('Slvnv:simcoverage:object_titleStr_and_link:InvalidOrigin'));
        end
    catch MEx
        rethrow(MEx);
    end

    function str=sf_obj_link(cvId,sfId,commandType,isLinked)
        if(sf('get',sfId,'.isa')==sf('get','default','state.isa'))




            rootIds=cv('RootsIn',cv('get',cvId,'.modelcov'));
            for idx=1:numel(rootIds)
                allChildren=cv('DecendentsOf',cv('get',rootIds(idx),'.topSlsf'));

                ccvId=cv('find',allChildren,'slsfobj.origin',2,'slsfobj.handle',sfId);
                if~isempty(ccvId)

                    ccvId=ccvId(1);
                    break;
                end
            end
            str=['"',cvi.ReportUtils.obj_diag_named_link(ccvId,[],commandType,isLinked),'"'];
        elseif(sf('get',sfId,'.isa')==sf('get','default','junction.isa'))

            str=[getString(message('Slvnv:simcoverage:cvhtml:Junction')),' #',num2str(sf('get',sfId,'.number'))];
        else
            str=[getString(message('Slvnv:simcoverage:cvhtml:Port')),' ',sf('get',sfId,'.labelString')];
        end
