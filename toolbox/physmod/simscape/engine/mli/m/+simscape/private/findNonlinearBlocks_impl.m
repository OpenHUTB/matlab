function outputBlockList=findNonlinearBlocks_impl(model)








    try
        model=pm_charvector(model);

        if contains(model,'.')
            if endsWith(model,'.mdl')||endsWith(model,'.slx')
                [~,modelName,~]=fileparts(model);
            else
                error(message('physmod:simscape:engine:mli:findNonlinearBlocks:InvalidModelName'));
            end
        else
            modelName=model;
        end


        if bdIsLoaded(modelName)
            alreadyLoaded=1;
            modelHandle=get_param(modelName,'Handle');
        else
            alreadyLoaded=0;
            modelHandle=load_system(modelName);
        end




        solverBlocks=find_system(modelHandle,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'SubClassName','solver');

        if isempty(solverBlocks)
            disp(message('physmod:simscape:engine:mli:findNonlinearBlocks:NoSimscapeNetworks').getString);
            outputBlockList={};
        else

            k=1;

            switchedLinearCounter=0;

            sp=NetworkEngine.SolverParameters;
            try
                [sf,ins,outs]=simscape.compiler.sli.componentModel(modelHandle,true);
            catch
                disp(message('physmod:common:exec:ime:kernel:ee:UnableToCompile').getString);
                outputBlockList={};
                return
            end
            if~iscell(sf)
                sf={sf};
                ins={ins};
                outs={outs};
            end
            for num=1:numel(sf)
                ds=simscape.compileModel(...
                sf{num},...
                'InputFilteringFcn',ins{num},...
                'OutputFilteringFcn',outs{num},...
                'ResidualTolerance',sp.ResidualTolerance);

                ssys=NetworkEngine.SolverSystem(ds);
                if ssys.IsCondSwitchedLinear
                    switchedLinearCounter=switchedLinearCounter+1;
                else
                    disp(message('physmod:simscape:engine:mli:findNonlinearBlocks:FoundNonlinearBlocks').getString);

                    firstK=k;


                    for i=1:length(ssys.EquationData)
                        if~ssys.EquationData(i).switched_linear
                            varList{k,1}=ssys.EquationData(i).object;%#ok<AGROW>
                            k=k+1;
                        end
                    end

                    disp(unique(varList(firstK:k-1)));
                end
            end

            disp(message('physmod:simscape:engine:mli:findNonlinearBlocks:NumberLinearNetworks',num2str(switchedLinearCounter)).getString);


            if~exist('varList','var')
                outputBlockList={};
            else
                disp(message('physmod:simscape:engine:mli:findNonlinearBlocks:NumberNonlinearNetworks',num2str(numel(sf)-switchedLinearCounter)).getString);
                outputBlockList=unique(varList);
            end
        end


        if~alreadyLoaded
            close_system(modelHandle)
        end
    catch exception
        throwAsCaller(exception);
    end
end
