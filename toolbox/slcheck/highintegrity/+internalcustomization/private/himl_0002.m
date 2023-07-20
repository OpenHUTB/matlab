function himl_0002

    rec=getNewCheckObject('mathworks.hism.himl_0002',false,@hCheckAlgo,'None');

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;


    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(~)
    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            if isa(fcnObjs{i},'Stateflow.EMChart')||isa(fcnObjs{i},'Stateflow.EMFunction')
                FailingObjs=[FailingObjs;getFailingEMLFunctions(fcnObjs{i})];%#ok<AGROW>
            end
        end
    end

end

function FailObjs=getFailingEMLFunctions(eml_obj)
    FailObjs=[];
    dataObjects=eml_obj.find('-isa','Stateflow.Data');

    for idx=1:length(dataObjects)

        thisObject=dataObjects(idx);





        if(strcmp(thisObject.Scope,'Data Store Memory')==1)||...
            (strcmp(thisObject.Scope,'Output')&&sf('get',thisObject.Id,'data.inPlace.isInPlace'))
            continue;
        end


        if strcmp(thisObject.DataType,'Inherit: Same as Simulink')||...
            strcmp(thisObject.DataType,'Inherit: From definition in chart')
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',thisObject);
            tempObj.Status=DAStudio.message('ModelAdvisor:hism:himl_0002_warn1');
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0002_rec_action1');
            FailObjs=[FailObjs;tempObj];%#ok<AGROW>
        end

        type=thisObject.DataType;
        if~ignoredTypes(type)

            if strcmp(thisObject.Props.Complexity,'Inherited')==1
                tempObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempObj,'SID',thisObject);
                tempObj.Status=DAStudio.message('ModelAdvisor:hism:himl_0002_warn2');
                tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0002_rec_action2');
                FailObjs=[FailObjs;tempObj];%#ok<AGROW>
            end
        end
    end
end

function status=ignoredTypes(type)



    status=~isempty(regexp(type,'^Bus:','once'))||~isempty(regexp(type,'^Enum:','once'))||~isempty(regexp(type,'^boolean','once'));
end
