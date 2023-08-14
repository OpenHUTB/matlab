function data=writeCoderTargetDataInclude(hCS)





    hwResourceFname='MW_target_hardware_resources.h';
    [newResourceInfo,data]=loc_getNewResourcesInfo(hCS,hwResourceFname);
    resourceFileNeedsUpdate=~isequal(newResourceInfo,...
    loc_getOldResourcesInfo(hwResourceFname));


    if resourceFileNeedsUpdate
        fid=fopen(hwResourceFname,'w');
        if~isequal(fid,-1)
            fprintf(fid,newResourceInfo);
            fclose(fid);
        end
    end
end


function data=loc_getParameterDataInfo(hObj)


    data=[];
    info=codertarget.parameter.getParameterDialogInfo(hObj,false);
    for i=1:length(info.ParameterGroups)
        for j=1:length(info.Parameters{i})
            paramType=info.Parameters{i}{j}.Type;
            if isequal(paramType,'combobox')&&info.Parameters{i}{j}.SaveValueAsString
                val=info.Parameters{i}{j}.Entries;
            elseif isequal(paramType,'checkbox')||isequal(paramType,'pushbutton')
                val=[];
            else
                continue
            end
            paramName=info.Parameters{i}{j}.Storage;
            if~isempty(paramName)
                pos=strfind(paramName,'.');
                if isempty(pos)
                    data.(paramName)=val;
                else
                    s1=paramName(1:pos-1);
                    s2=paramName(pos+1:end);
                    data.(s1).(s2)=val;
                end
            end
        end
    end
end


function isMT=loc_isSetForMultiTasking(hObj)



    isExe=isequal(get_param(getModel(hObj),'ModelReferenceTargetType'),'NONE');



    if isExe&&strcmp(get_param(hObj,'SolverType'),'Fixed-step')&&...
        ~strcmp(get_param(hObj,'SampleTimeConstraint'),'STIndependent')


        switch get_param(hObj,'SolverMode')
        case{'Auto','MultiTasking'}
            isMT=true;
        case 'SingleTasking'
            isMT=false;
        end
    else
        isMT=false;
    end
end


function[newResourceInfo,data]=loc_getNewResourcesInfo(hCS,hw_resource_fname)



    map=loc_getParameterDataInfo(hCS);
    data=codertarget.data.getData(hCS);

    data1.Multi_tasking_mode=loc_isSetForMultiTasking(hCS);

    resourceFileWriter=codertarget.data.coderTargetDataIncludeWriter;
    resourceFileWriter.writeLine('#ifndef PORTABLE_WORDSIZES');
    resourceFileWriter.writeLine('#ifdef __MW_TARGET_USE_HARDWARE_RESOURCES_H__');
    resourceFileWriter.writeLine(['#ifndef __',upper(strrep(hw_resource_fname,'.','_')),'__']);
    resourceFileWriter.writeLine(['#define __',upper(strrep(hw_resource_fname,'.','_')),'__']);
    resourceFileWriter.writeLine('');

    resourceFileWriter.writeDefines(data1,map,'');



    include_files=codertarget.targethardware.getTargetHardwareIncludeFiles(hCS);
    include_files=unique(strtrim(include_files),'stable');

    for i=1:length(include_files)
        resourceFileWriter.writeCoderTargetIncludes(include_files{i});
    end
    resourceFileWriter.writeLine('');

    resourceFileWriter.writeDefines(data,map,'');
    resourceFileWriter.writeLine('');

    resourceFileWriter.writeLine(['#endif /* __',upper(strrep(hw_resource_fname,'.','_')),'__ */']);
    resourceFileWriter.writeLine('');
    resourceFileWriter.writeLine('#endif');
    resourceFileWriter.writeLine('');
    resourceFileWriter.writeLine('#endif');
    newResourceInfo=resourceFileWriter.returnContent();
end


function oldResourceInfo=loc_getOldResourcesInfo(hw_resource_fname)



    if(isfile(fullfile(pwd,hw_resource_fname)))
        fid=fopen(hw_resource_fname,'rt');
        oldResourceInfo=fread(fid,[1,inf],'*char');
        fclose(fid);
    else
        oldResourceInfo='';
    end
end