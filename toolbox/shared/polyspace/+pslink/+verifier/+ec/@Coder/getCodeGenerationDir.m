



function cgDirInfo=getCodeGenerationDir(systemName)


    cgDirInfo=cell(0,2);

    [codeGenDir,codeGenName]=targetsprivate('targets_get_build_dir',systemName);
    if~isempty(codeGenDir)&&~isempty(codeGenName)
        cgDirInfo={codeGenDir,codeGenName};
    else


        systemsNames=split(systemName,'/');
        if strcmpi(systemsNames{1},systemsNames{end})
            hdl=get_param(systemName,'Handle');
            t=Simulink.ModelReference.Conversion.NameUtils;
            validName=t.getValidModelName(hdl);



            [codeGenDir,codeGenName]=targetsprivate('targets_get_build_dir',bdroot(systemName));
            if~isempty(codeGenDir)&&~isempty(codeGenName)
                [beginIdx,endIdx]=regexp(codeGenDir,bdroot(systemName));
                if~isempty(beginIdx)&&~isempty(endIdx)
                    codeGenDir=replaceBetween(codeGenDir,...
                    beginIdx(end),...
                    endIdx(end),...
                    validName);
                    codeGenName=validName;
                    cgDirInfo={codeGenDir,codeGenName};
                end
            end
        end
    end



