classdef StudentMATLABFunctionBlockData<learning.assess.assessments.StudentAssessment


    properties(Constant)
        type='MATLABFunctionBlockData';
    end

    properties
DataParameters
    end

    methods
        function obj=StudentMATLABFunctionBlockData(props)
            obj.validateInput(props);
            obj.DataParameters=props.DataParameters;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;
            eachIsCorrect=zeros(1,length(obj.DataParameters));





            rt=sfroot;
            sfData=find(rt,'-isa','Stateflow.Data');
            obj.compileIfNecessary(userModelName);

            for idx=1:length(obj.DataParameters)


                currentDataParameters=obj.DataParameters(idx);
                fields=fieldnames(currentDataParameters);
                emptyFields=cellfun(@(x)isempty(currentDataParameters.(x)),fields);
                currentDataParameters=rmfield(currentDataParameters,fields(emptyFields));

                expectedVals=struct2cell(currentDataParameters);
                if~isrow(expectedVals)
                    expectedVals=expectedVals';
                end

                for jdx=1:length(sfData)
                    if contains(sfData(jdx).Path,userModelName)
                        dataVals=get(sfData(jdx),fieldnames(currentDataParameters));
                        eachIsCorrect(idx)=isequal(dataVals,expectedVals);
                        if eachIsCorrect(idx)
                            break
                        end
                    end
                end
            end

            if all(eachIsCorrect)
                isCorrect=true;
            end

        end

        function requirementString=generateRequirementString(obj)
            messageName='learning:simulink:genericRequirements:mlfuncData';
            allParametersText='';
            parameterNames=fieldnames(obj.DataParameters);

            for idx=1:length(obj.DataParameters)
                for jdx=1:length(parameterNames)
                    if~isempty(obj.DataParameters(idx).(parameterNames{jdx}))
                        currentParameterText=['          ',parameterNames{jdx},': ',obj.DataParameters(idx).(parameterNames{jdx})];
                        allParametersText=[allParametersText,newline,currentParameterText];
                    end
                end
                if idx~=length(obj.DataParameters)
                    allParametersText=[allParametersText,newline];
                end
            end
            requirementString=message(messageName,allParametersText).getString();
        end

    end

    methods(Access=protected)
        function validateInput(~,props)



            if isstruct(props)&&isfield(props,'DataParameters')
                eachHasProps=zeros(1,length(props));
                for idx=1:length(props)
                    eachHasProps(idx)=isstruct(props(idx).DataParameters);
                end
                if all(eachHasProps)
                    hasAllProps=true;
                end
            else
                hasAllProps=false;
            end

            if~hasAllProps
                error(message('learning:simulink:resources:MissingParameters'));
            end

        end

        function compileIfNecessary(obj,userModelName)
            if any(contains(fieldnames(obj.DataParameters),'Compiled'))
                feval(userModelName,[],[],[],'compile');
                feval(userModelName,[],[],[],'term');
            end
        end

    end
end
