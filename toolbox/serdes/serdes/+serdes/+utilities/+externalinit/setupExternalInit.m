function setupExternalInit(varargin)



















    if nargin==0

        model=bdroot;
        targetBlocks={'Tx','Rx'};



        revert=serdes.utilities.externalinit.hasExternalInitFiles;
        if revert
            userSelection=questdlg('External Init was previously enabled.  This action will disable and delete the associated files.',...
            'Revert External Init',...
            'No');
            switch userSelection
            case 'No'
                return
            case 'Yes'

            case 'Cancel'
                return
            end
        end
    elseif nargin==3
        if~(strcmp(varargin{2},'Tx')||strcmp(varargin{2},'Rx'))&&...
            ~isa(varargin{3},'logical')
            error(message('serdes:utilities:InvalidArgument'))
        end
        model=varargin{1};
        if~serdes.utilities.externalinit.hasExternalInitFiles
            targetBlocks={'Tx','Rx'};
        else
            targetBlocks=varargin(2);
        end
        revert=varargin{3};
    else
        error(message('serdes:utilities:InvalidArgument'))
    end

    mws=get_param(model,'ModelWorkspace');
    requiredMWSElements=["SampleInterval","ChannelImpulse","RowSize","Aggressors","ImpulseMatrix","SerdesIBIS"];
    if~isempty(mws)&&~all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
        error(message('serdes:utilities:NotSerDesToolboxModel'))
    end

    if revert
        revertExternalInit(model);
    else
        enableExternalInit(model,targetBlocks);
    end
end
function enableExternalInit(model,targetBlocks)
    sizeTargetBlocks=size(targetBlocks,2);


    extFuncCallSaved=strings(2,1);
    for currentBlock=1:sizeTargetBlocks
        currentFileName=[lower(targetBlocks{currentBlock}),'Init.m'];
        openingComment='% NOTE: This init function has been converted to external init.  Do not edit here.';
        openingComment=[openingComment,newline,'% Go to ',currentFileName,' for customization.',newline];%#ok<AGROW>
        currentOpenFile=fopen(currentFileName,'w');
        mlFcnName=[model,'/',targetBlocks{currentBlock},'/Init/Initialize Function/MATLAB Function'];
        emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
        splitInit=splitlines(emChart.Script);
        funcPosition=startsWith(splitInit,'function');
        funcCall=splitInit(funcPosition);
        extFuncSig=strrep(funcCall,'impulseEqualization',[lower(targetBlocks{currentBlock}),'Init']);
        extFuncCall=erase(extFuncSig,'function ');

        lentToErase=[" %#ok<INUSD>"," %#ok<INUSL>"];
        extFuncCall=erase(extFuncCall,lentToErase);
        funcCall=erase(funcCall,lentToErase);
        splitInit(funcPosition)=extFuncSig;
        fprintf(currentOpenFile,'%s',char(join(splitInit,newline)));

        simulinkInitCode=[openingComment,char(funcCall),newline,char(extFuncCall),';'];
        emChart.Script=simulinkInitCode;
        fclose(currentOpenFile);
        if strcmp(targetBlocks{currentBlock},'Tx')
            extFuncCallSaved(1)=[char(strrep(extFuncCall,'ImpulseIn','ChannelImpulse')),';'];
        else
            extFuncCallSaved(2)=[char(strrep(extFuncCall,'ImpulseIn','ImpulseOut')),';'];
        end
    end

    if serdes.utilities.externalinit.hasExternalInitFiles
        oldRunScript=fileread('runExternalInit.m');
        oldRunScriptSplit=splitlines(oldRunScript);
        if strcmp(targetBlocks{1},'Tx')
            functionName=' = rxInit(';
            extFuncCallSavedPosition=2;
        else
            functionName=' = txInit(';
            extFuncCallSavedPosition=1;
        end
        funcPosition=contains(oldRunScriptSplit,functionName);
        extFuncCallSaved(extFuncCallSavedPosition)=oldRunScriptSplit(funcPosition);
    end
    createRunScript(extFuncCallSaved);
end
function revertExternalInit(model)
    if~serdes.utilities.externalinit.hasExternalInitFiles
        return
    end
    targetBlocks={'Tx','Rx'};
    for currentBlock=1:2

        currentFileName=[lower(targetBlocks{currentBlock}),'Init.m'];
        currentOpenFileContents=fileread(currentFileName);

        extInitCode=strrep(currentOpenFileContents,[lower(targetBlocks{currentBlock}),'Init'],'impulseEqualization');

        mlFcnName=[model,'/',targetBlocks{currentBlock},'/Init/Initialize Function/MATLAB Function'];
        emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
        emChart.Script=extInitCode;
    end

    delete txInit.m rxInit.m runExternalInit.m;
end
function createRunScript(functionSignature)

    runInitFile=fopen('runExternalInit.m','w');
    fprintf(runInitFile,'%s',['% runExternalInit - Script to run External Init functions (txInit.m and rxInit.m)',newline]);
    fprintf(runInitFile,'%s',['% identically to current SerDes Toolbox Simulink model.',newline,newline]);
    fprintf(runInitFile,'%s',['% Load required model workspace variables into base workspace',newline]);
    fprintf(runInitFile,'%s',['serdes.utilities.externalinit.refreshBaseWSWithModelWS;',newline]);
    fprintf(runInitFile,'%s',['% Call Tx and Rx Init in order',newline]);
    fprintf(runInitFile,'%s',[functionSignature(1),newline]);
    fprintf(runInitFile,'%s',[functionSignature(2),newline]);
    fprintf(runInitFile,'%s',['% Anaylze equalized impulse response',newline]);
    fprintf(runInitFile,'%s','serdes.utilities.externalinit.plotExternalInit;');
    fclose(runInitFile);
end