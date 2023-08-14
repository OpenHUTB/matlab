function linadv=generateAdvisor(Jobj,sl,storageindex,op)


    if sl.Options.StoreAdvisor
        params=sl.Parameters;
        mdl=sl.Model;
        if~isempty(params)
            for i=1:numel(params)
                params(i).Value=params(i).Value(storageindex);
            end
        end

        J=LocalGetJacobianStructure(Jobj);


        mdlHierInfo=linearize.advisor.utils.getParentModels(mdl);

        mdlData=struct(...
        'Model',mdl,...
        'J',J,...
        'OperatingPoint',op,...
        'Parameters',params,...
        'Options',sl.Options,...
        'MdlHierInfo',mdlHierInfo);

        linadv=linearize.advisor.LinearizationAdvisor(mdlData);
    else
        linadv=[];
    end

    function J=LocalGetJacobianStructure(Jobj)

        J=getJacobianStructure(Jobj);

        J=LocalAddPortInfo2J(J);


        reps=getObjectReplacements(Jobj);
        if~isempty(reps)
            rchObj=[reps.CompiledBlockHandle]';
            rch=[J.Mi.Replacements.CompiledBlockHandle]';
            notinJ=~ismember(rchObj,rch);
            J.Mi.Replacements=[J.Mi.Replacements;reps(notinJ)];
        end

        function J=LocalAddPortInfo2J(J)
            import linearize.advisor.utils.*
            J.Mi.OutputInfo=addPorts2BlockInfo(J.Mi.OutputInfo,'outport');
            J.Mi.InputInfo=addPorts2BlockInfo(J.Mi.InputInfo,'inport');