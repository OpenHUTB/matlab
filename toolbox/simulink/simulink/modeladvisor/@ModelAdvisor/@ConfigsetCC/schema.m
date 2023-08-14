function schema




    parentpkg=findpackage('Simulink');
    parentcls=findclass(parentpkg,'CustomCC');


    hCreateInPackage=findpackage('ModelAdvisor');

    hThisClass=schema.class(hCreateInPackage,'ConfigsetCC',parentcls);


    m=schema.method(hThisClass,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


    p=schema.prop(hThisClass,'ModelAdvisorConfigurationFile','ustring');
    p.setFunction=@setCallback;




    p=schema.prop(hThisClass,'ShowAdvisorChecksEditTime','slbool');
    p.setFunction=@setCallbackShowAdvisorChecksEditTime;




    function newvalue=setCallback(obj,value)
        newvalue=value;
        oldvalue=obj.ModelAdvisorConfigurationFile;

        if strcmp(oldvalue,newvalue)
            return
        end

        bd=obj.up;
        while~(isempty(bd)||bd.isa('Simulink.BlockDiagram'))
            bd=bd.up;
        end

        configFileName=value;
        if~isempty(bd)

            fileIsValid=false;
            if isempty(configFileName)
                fileIsValid=true;
            else
                [~,~,ext]=fileparts(configFileName);
                if strcmp(ext,'.json')&&exist(configFileName,'file')
                    jsonData=jsondecode(fileread(configFileName));
                    if isfield(jsonData,'SimulinkVersion')&&(str2double(jsonData.SimulinkVersion)>=10.3)&&isfield(jsonData.Tree,'ConstraintXML')
                        fileIsValid=true;
                    end
                end
            end
            if~fileIsValid
                newvalue=oldvalue;
                DAStudio.error("ModelAdvisor:engine:InvalidModelAdvisorConfigurationFile",configFileName);
            else



                if~isempty(bd)
                    set_param(bd.Handle,'Dirty','on');
                end

                editControl=edittimecheck.EditTimeEngine.getInstance();
                editControl.setModelConfiguration(bd.getFullName,configFileName);

            end
        end


        function newvalue=setCallbackShowAdvisorChecksEditTime(obj,value)
            newvalue=value;
            oldvalue=obj.ShowAdvisorChecksEditTime;

            if strcmp(oldvalue,newvalue)
                return
            end

            bd=obj.up;
            while~(isempty(bd)||bd.isa('Simulink.BlockDiagram'))
                bd=bd.up;
            end

            if~isempty(bd)

                set_param(bd.Handle,'Dirty','on');
                edittime.setAdvisorChecking(bd.Name,newvalue);
            end
