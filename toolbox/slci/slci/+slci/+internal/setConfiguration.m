function setConfiguration(mdlName)




    slciModel=slci.simulink.Model(mdlName);
    slciModel.AddConstraints();
    constraints=slciModel.getConstraints();
    for i=1:numel(constraints)




        if~constraints{i}.getCompileNeeded()
            [failures,~]=constraints{i}.checkCompatibility();


            for j=numel(failures):-1:1
                try
                    if failures(j).getConstraint.hasAutoFix()
                        failures(j).getConstraint.fix();
                    end
                end
            end
        end
    end

