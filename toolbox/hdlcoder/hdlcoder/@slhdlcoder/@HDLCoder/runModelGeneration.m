function doOnlyMdlGen=runModelGeneration(this,gp,hs)




    [genCode,genModel,~]=this.getCodeModelTBParams;
    doOnlyMdlGen=~genCode;

    if genModel
        topMdlName=bdroot(gp.getTopNetwork.Name);
        hdldisp(message('hdlcoder:makehdl:MakehdlParamUpdateLog',topMdlName,'GenerateModel'));
    end

    modelgenPersistentData=struct();
    modelgenPersistentData.highlightMessages=containers.Map;
    modelgenPersistentData.cpeTable=containers.Map('KeyType','double','ValueType','any');
    modelgenPersistentData.genModel=genModel;






    gp.setTriggerHierarchyAnalyzer;

    numModels=numel(this.AllModels);
    for mdlIdx=1:numModels
        this.mdlIdx=mdlIdx;
        mdlName=this.AllModels(mdlIdx).modelName;
        p=pir(mdlName);
        this.PirInstance=p;

        p.doPreModelgenTasks;


        this.getIncrementalCodeGenDriver.loadHDLCodeGenStatus(this,p.ModelName);





        if genModel
            gp.startTimer('Do Model Generation','Phase dmg');

            oldValue=get_param(0,'CopyBlkRequirement');
            set_param(0,'CopyBlkRequirement','off');

            genValidationModel=(mdlIdx==numModels)&&(this.getParameter('generatevalidationmodel')==1);

            modelgenPersistentData.firstModel=mdlIdx==1;
            modelgenPersistentData.lastModel=mdlIdx==numModels;
            doModelGeneration(this,p,modelgenPersistentData,genValidationModel);

            set_param(0,'CopyBlkRequirement',oldValue);
            if~genCode

                this.getIncrementalCodeGenDriver().saveHDLCodeGenerationStatus(this,p);
                reportMessages(this);
            end
            gp.stopTimer;
        else


            modelgenPersistentData.firstModel=mdlIdx==1;
            modelgenPersistentData.lastModel=mdlIdx==numModels;
            infile=p.ModelName;
            outfile='';
            hyperlinksInLog=~this.getParameter('BuildToProtectModel');
            this.BackEnd=slhdlcoder.SimulinkBackEnd(p,...
            'InModelFile',infile,...
            'OutModelFile',outfile,...
            'HyperlinksInLog',hyperlinksInLog);
            this.BackEnd.postModelgenTasks(p,modelgenPersistentData);


            this.getIncrementalCodeGenDriver().modelGenerationPredicate(this,p);
        end
    end

    if~genCode

        success=false;
        this.cleanup(hs,success);
    else


        hdlresetgcb(this.ModelConnection.ModelName);
    end

    gp.setTriggerHierarchyAnalyzer;

end


function doModelGeneration(this,p,mpd,genValidationModel)
    try
        this.generateModel(p,mpd);
    catch me
        if(isequal(me.identifier,'hdlcoder:makehdl:modelrefOutOfDate'))
            rethrow(me)
        end
        if(isequal(me.identifier,'hdlcoder:engine:createtargetmodel'))
            rethrow(me)
        end
        hdldisp(getReport(me),0);
        errObj=message('hdlcoder:engine:MdlGenError');
        this.addCheck(this.ModelName,'Error',errObj);
        this.addCheck(this.ModelName,'Error',me);
    end


    if genValidationModel
        if strcmp(this.OrigModelName,this.OrigStartNodeName)
            warnObj=message('hdlcoder:makehdl:ModelgenNotSupported');
            this.addCheck(this.ModelName,'Warning',warnObj);
        else
            try
                gc=cosimtb.gencoverifymdl('CoverifyBlockAndDut',this,p);
                gc.doIt;
                this.CoverifyModelName=gc.getCosimModelName;
            catch me
                errObj=message('hdlcoder:engine:ValMdlGenError',me.message);
                this.addCheck(this.ModelName,'Error',errObj);
            end
        end
    end
end


