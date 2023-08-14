classdef constraintManager
    methods(Static)
        function createParamterConstraint(constraintData,constraintName,hConstraint)
            numberOfRules=constraintData.getNrofRules();
            hConstraint.Name=constraintName;
            for ruleIndex=1:numberOfRules
                ruleData=constraintData.getRuleData(ruleIndex-1);
                DataType=char(ruleData.getDataType());
                Complexity=cell(ruleData.getAttributes('Complexity'));
                Dimension=cell(ruleData.getAttributes('Dimension'));
                Sign=cell(ruleData.getAttributes('Sign'));
                Finiteness=cell(ruleData.getAttributes('Finiteness'));
                Minimum=char(ruleData.getMinimum());
                Maximum=char(ruleData.getMaximum());
                customConstraintVal=char(ruleData.getCustomConstraint());
                CustomErrorMessage=char(ruleData.getCustomErrorMsg());
                hConstraint.addParameterConstraintRule('DataType',DataType,'Complexity',Complexity,...
                'Dimension',Dimension,'Sign',Sign,'Finiteness',Finiteness,...
                'Minimum',Minimum,'Maximum',Maximum,'CustomConstraint',customConstraintVal,...
                'CustomErrorMessage',CustomErrorMessage);
            end
        end

        function SetConstraintToMaskEditor(hconstraint,paramConstraintName,location,MaskEditor)
            numRules=numel(hconstraint.ConstraintRules);
            MaskEditor.createConstraint(paramConstraintName,location,numRules);
            for index=1:numRules
                MaskEditor.setMaskConstraintDataTypeVal(paramConstraintName,hconstraint.ConstraintRules(index).DataType,index-1);
                MaskEditor.setMaskConstraintAttribs(paramConstraintName,'Complexity',hconstraint.ConstraintRules(index).Complexity,index-1);
                MaskEditor.setMaskConstraintAttribs(paramConstraintName,'Dimension',hconstraint.ConstraintRules(index).Dimension,index-1);
                MaskEditor.setMaskConstraintAttribs(paramConstraintName,'Sign',hconstraint.ConstraintRules(index).Sign,index-1);
                MaskEditor.setMaskConstraintAttribs(paramConstraintName,'Finiteness',hconstraint.ConstraintRules(index).Finiteness,index-1);
                MaskEditor.setMaskConstraintVal(paramConstraintName,'Minimum',hconstraint.ConstraintRules(index).Minimum,index-1);
                MaskEditor.setMaskConstraintVal(paramConstraintName,'Maximum',hconstraint.ConstraintRules(index).Maximum,index-1);
                MaskEditor.setMaskConstraintVal(paramConstraintName,'CustomConstraint',hconstraint.ConstraintRules(index).CustomConstraint,index-1);
                MaskEditor.setMaskConstraintVal(paramConstraintName,'CustomErrorMessage',hconstraint.ConstraintRules(index).CustomErrorMessage,index-1);
            end
        end

        function addParameterConstraintToMask(frame,aMaskObj)
            numberOfConstraints=frame.getNumberOfConstraints();
            for index=1:numberOfConstraints
                constraintName=char(frame.getConstraintName(index-1));
                if~contains(constraintName,':')
                    hConstraint=Simulink.Mask.Constraints;
                    hConstraint.Name=constraintName;
                    numberOfRules=frame.getNumberOfRulesInConstraint(constraintName);
                    for ruleIndex=1:numberOfRules
                        DataType=char(frame.GetValidationAttribsforDataType(constraintName,ruleIndex-1));
                        Complexity=cell(frame.GetValidationAttribsforType(constraintName,'Complexity',ruleIndex-1));
                        Dimension=cell(frame.GetValidationAttribsforType(constraintName,'Dimension',ruleIndex-1));
                        Sign=cell(frame.GetValidationAttribsforType(constraintName,'Sign',ruleIndex-1));
                        Finiteness=cell(frame.GetValidationAttribsforType(constraintName,'Finiteness',ruleIndex-1));
                        Minimum=char(frame.getMaskConstraintVal(constraintName,'Minimum',ruleIndex-1));
                        Maximum=char(frame.getMaskConstraintVal(constraintName,'Maximum',ruleIndex-1));
                        customConstraintVal=char(frame.getMaskConstraintVal(constraintName,'CustomConstraint',ruleIndex-1));
                        CustomErrorMessage=char(frame.getMaskConstraintVal(constraintName,'CustomErrorMessage',ruleIndex-1));
                        hConstraint.addParameterConstraintRule('DataType',DataType,'Complexity',...
                        Complexity,'Dimension',Dimension,'Sign',Sign,'Finiteness',Finiteness,'Minimum',Minimum,...
                        'Maximum',Maximum,'CustomConstraint',customConstraintVal,...
                        'CustomErrorMessage',CustomErrorMessage);
                    end
                    aMaskObj.addParameterConstraint(hConstraint);
                    clear hConstraint;
                end
            end
        end

        function addCrossParameterConstraintToMask(frame,aMaskObj)
            numberOfCustomConstraints=frame.getNumberOfCustomConstraints();
            for index=1:numberOfCustomConstraints
                customConstraintName=char(frame.getCustomConstraintName(index-1));
                constraintRule=char(frame.getCustomConstraintAttrib(customConstraintName,'Rule'));
                constraintErrorMsg=char(frame.getCustomConstraintAttrib(customConstraintName,'ErrorMessage'));
                aMaskObj.addCrossParameterConstraint('Name',customConstraintName,'MATLABexpression',constraintRule,...
                'ErrorMessage',constraintErrorMsg);
            end
        end

        function addCrossParameterConstraintToMaskEditor(aMaskObj,MaskEditor)
            numCustomConstraints=numel(aMaskObj.CrossParameterConstraints);
            for i=1:numCustomConstraints
                hCustomconstraint=aMaskObj.CrossParameterConstraints(i);
                MaskEditor.createCustomConstraint(hCustomconstraint.Name);
                MaskEditor.SetCustomConstraintAttrib(hCustomconstraint.Name,'Rule',hCustomconstraint.MATLABexpression);
                MaskEditor.SetCustomConstraintAttrib(hCustomconstraint.Name,'ErrorMessage',hCustomconstraint.ErrorMessage);
            end
        end

        function addConstraintToMaskEditor(aMaskParameters,aMaskObj,MaskEditor)
            numParamConstraints=numel(aMaskObj.ParameterConstraints);
            for i=1:numParamConstraints
                hconstraint=aMaskObj.ParameterConstraints(i);
                constraintManager.SetConstraintToMaskEditor(hconstraint,hconstraint.Name,"",MaskEditor);
            end

            constraintNames={aMaskParameters(:).ConstraintName}';
            numConstraints=numel(constraintNames);
            matFileNames=string.empty(0,numConstraints);
            for index=1:numConstraints
                splitName=strsplit(char(constraintNames(index)),':');
                if numel(splitName)==2
                    matFileNames(index)=splitName(1);
                end
            end
            matFileNames=unique(matFileNames);
            matFileNames=rmmissing(matFileNames);
            numMatFiles=numel(matFileNames);
            for k=1:numMatFiles
                constraintManager.SetSharedConstraintToMaskEditor(matFileNames(k),MaskEditor);
            end
            constraintManager.addCrossParameterConstraintToMaskEditor(aMaskObj,MaskEditor);
            MaskEditor.UpdateConstraintCombo();
        end

        function setOldConstraintsToMask(aMaskObj,aOldMaskObj)
            aMaskObj.removeAllCrossParameterConstraints();
            if isfield(aOldMaskObj,'CrossParameterConstraints')
                numCrossParamConstraint=length(aOldMaskObj.CrossParameterConstraints);
                for crossParamIndex=1:numCrossParamConstraint
                    crossParamConstraint=aOldMaskObj.CrossParameterConstraints{crossParamIndex};
                    aMaskObj.addCrossParameterConstraint('Name',crossParamConstraint.Name,'MATLABexpression',crossParamConstraint.MATLABexpression,...
                    'ErrorMessage',crossParamConstraint.ErrorMessage);
                end
            end

            aMaskObj.removeAllParameterConstraints();
            if isfield(aOldMaskObj,'ParameterConstraints')
                numSingleParamConstraint=length(aOldMaskObj.ParameterConstraints);
                for singleParamIndex=1:numSingleParamConstraint
                    aMaskObj.addParameterConstraint(aOldMaskObj.ParameterConstraints{singleParamIndex});
                end
            end
        end

        function aStandaloneMaskObject=addParameterConstraintToStandaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumParameterConstraints=length(aMaskObj.ParameterConstraints);
            for m=1:iNumParameterConstraints
                singleParamConstraint=Simulink.Mask.Constraints;
                singleParamConstraint.Name=aMaskObj.ParameterConstraints(m).Name;
                ruleLength=length(aMaskObj.ParameterConstraints(m).ConstraintRules);
                for r=1:ruleLength
                    singleRule=aMaskObj.ParameterConstraints(m).ConstraintRules(r);
                    singleParamConstraint.addParameterConstraintRule('DataType',singleRule.DataType,'Complexity',...
                    singleRule.Complexity,'Dimension',singleRule.Dimension,'Sign',singleRule.Sign,...
                    'Finiteness',singleRule.Finiteness,'Minimum',singleRule.Minimum,...
                    'Maximum',singleRule.Maximum,'CustomConstraint',singleRule.CustomConstraint,...
                    'CustomErrorMessage',singleRule.CustomErrorMessage);
                end
                aStandaloneMaskObject.ParameterConstraints{m}=singleParamConstraint;
            end
        end

        function aStandaloneMaskObject=addCrossParameterConstraintToSatndaloneMask(aMaskObj,aStandaloneMaskObject)
            iNumCrossParamConstraints=length(aMaskObj.CrossParameterConstraints);
            for k=1:iNumCrossParamConstraints
                crossParamConstraint=aMaskObj.CrossParameterConstraints(k);
                crossParamConstraint=struct('Name',crossParamConstraint.Name,'MATLABexpression',...
                crossParamConstraint.MATLABexpression,'ErrorMessage',crossParamConstraint.ErrorMessage);
                aStandaloneMaskObject.CrossParameterConstraints{k}=crossParamConstraint;
            end
        end

        function SetSharedConstraintToMaskEditor(matFileName,MaskEditor)
            if~contains(matFileName,'.mat')
                matFileName=strcat(matFileName,'.mat');
            end
            if exist(matFileName,'file')
                constraintList=load(matFileName);
                fields=fieldnames(constraintList);
                absMatFileName=which(matFileName);
                matFileName=erase(matFileName,'.mat');
                for i=1:numel(fields)
                    hconstraint=constraintList.(fields{i});
                    if isa(hconstraint,'Simulink.Mask.Constraints')
                        paramConstraintName=strcat(matFileName,':',hconstraint.Name);
                        constraintManager.SetConstraintToMaskEditor(hconstraint,paramConstraintName,absMatFileName,MaskEditor)
                    end
                end
                clear constraintList;
            end
        end

        function[errorMsg]=deleteSharedConstraint(absConstraintName)
            errorMsg='';
            data=strsplit(absConstraintName,':');
            if(numel(data)==2)
                matFileName=data{1};
                constraintNameToDelete=data{2};
                if~contains(matFileName,'.mat')
                    matFileName=strcat(matFileName,'.mat');
                end
                if exist(matFileName,'file')
                    constraintListFromMatFile=load(matFileName);
                    constraintListFromMatFile=constraintManager.deleteConstraintFromMatFile(constraintListFromMatFile,constraintNameToDelete);
                    try
                        save(matFileName,'-struct','constraintListFromMatFile');
                    catch error
                        errorMsg=error.message;
                    end
                end
            end
        end





        function constraintListFromMatFile=deleteConstraintFromMatFile(constraintListFromMatFile,constraintNameToDelete)
            constraintFieldNames=fieldnames(constraintListFromMatFile);
            for index=1:numel(constraintFieldNames)
                fieldname=constraintFieldNames{index};
                field=constraintListFromMatFile.(fieldname);
                constraintName=field.Name;
                if strcmp(constraintName,constraintNameToDelete)
                    constraintListFromMatFile=rmfield(constraintListFromMatFile,fieldname);
                end
            end
        end











        function errorMsg=saveConstraintToMatFile(constraintListFromJava)
            errorMsg='';
            mapIterator=constraintListFromJava.entrySet().iterator();
            while(mapIterator.hasNext())
                constraintListStruct=struct;
                constraintDataEntryFromJava=mapIterator.next();
                matFileName=constraintDataEntryFromJava.getKey();
                if~contains(matFileName,'.mat')
                    matFileName=strcat(matFileName,'.mat');
                end
                errorMsg=constraintManager.showErrorIfMatFilePathNotPresntInMatlabPath(matFileName);
                if~isempty(errorMsg)
                    return;
                end

                constraintListFromMatFile=struct;
                bmatFileExist=exist(matFileName,'file');
                if(bmatFileExist)
                    constraintListFromMatFile=load(matFileName);
                end
                constraintDataListFromJava=constraintDataEntryFromJava.getValue();
                numberOfConstraints=size(constraintDataListFromJava);
                for index=1:numberOfConstraints
                    constraintDataFromJava=constraintDataListFromJava.get(index-1);
                    absConstraintName=char(constraintDataFromJava.getName());
                    data=strsplit(absConstraintName,':');


                    if(numel(data)==2)
                        constraintName=data{2};




                        eval([constraintName,' = Simulink.Mask.Constraints']);


                        eval(['hConstraint = ',constraintName]);

                        constraintManager.createParamterConstraint(constraintDataFromJava,constraintName,hConstraint);
                        if(bmatFileExist)


                            constraintListFromMatFile=constraintManager.deleteConstraintFromMatFile(constraintListFromMatFile,constraintName);
                            constraintListFromMatFile.(constraintName)=hConstraint;
                        else
                            constraintListStruct.(constraintName)=hConstraint;
                        end
                    end
                end
                if(~bmatFileExist)
                    try
                        save(matFileName,'-struct','constraintListStruct');
                    catch error
                        errorMsg=error.message;
                    end
                else
                    try
                        save(matFileName,'-struct','constraintListFromMatFile');
                    catch error
                        errorMsg=error.message;
                    end

                end
            end
        end

        function absMatFileName=GetAbsMatFileName(matFileName)
            absMatFileName=which(matFileName);
            matFileLocation=fileparts(matFileName);



            if isempty(absMatFileName)&&~isempty(matFileLocation)
                absMatFileName=matFileName;
            end

            if isempty(absMatFileName)
                absMatFileName=strcat(pwd,filesep,matFileName);
            end
        end

        function errorMsg=showErrorIfMatFilePathNotPresntInMatlabPath(matFileName)
            errorMsg='';
            if strcmp(fileparts(matFileName),pwd)
                return;
            end


            pathCell=regexp(path,pathsep,'split');
            [constraintPath,tempMatFielName,extension]=fileparts(matFileName);
            if~isempty(constraintPath)
                if ispc
                    isPresentOnPath=any(strcmpi(constraintPath,pathCell));
                else
                    isPresentOnPath=any(strcmp(constraintPath,pathCell));
                end

                if~isPresentOnPath
                    errorMsg=DAStudio.message('Simulink:Masking:MatFileLocationIsNotPresentInMatLABPath',...
                    constraintPath,strcat(tempMatFielName,extension));
                    return;
                end
            end
        end

    end
end

