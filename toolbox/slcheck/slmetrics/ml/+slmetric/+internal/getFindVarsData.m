function data=getFindVarsData(system,analyzeModelReferences)

















    enumTypesOption=false;

    mdlrefOpt='on';
    if~analyzeModelReferences
        mdlrefOpt='off';
    end

    vars=Simulink.findVars(system,...
    'IncludeEnumTypes',enumTypesOption,...
    'SearchMethod','cached',...
    'SearchReferencedModels',mdlrefOpt);


    data=struct('Name',{},'Source',{},'SourceType',{},'Users',{},...
    'Category',{},'Class',{});
    entryToRemove=false(size(vars));


    validParamClasses={'single','double','uint8','uint16','uint32',...
    'int8','int16','int32','boolean','logical','struct',...
    'char','cell'};

    for i=length(vars):-1:1
        var=vars(i);


        evalutedObject=[];

        try
            switch var.SourceType
            case 'base workspace'
                evalutedObject=evalin('base',var.Name);

            case 'model workspace'
                hws=get_param(var.Source,'modelworkspace');



                evalutedObject=getVariable(hws,var.Name);

            case 'data dictionary'





                dictObj=Simulink.data.dictionary.open(var.Source);


                sectObj=getSection(dictObj,'Design Data');
                entryObj=getEntry(sectObj,var.Name);
                evalutedObject=getValue(entryObj);
                close(dictObj);


            case 'mask workspace'











                entryToRemove(i)=true;





                data(i).Name='';

            case{'MATLAB file','dynamic class'}


                data(i).Name=var.Name;
                data(i).Class=var.Name;
                data(i).Category='d';
                data(i).Source=var.Source;
                data(i).SourceType=var.SourceType;
                data(i).Users=loc_getUSerSIDs(var.Users);

            otherwise
                assert(false,'Unsupported Source type.')
            end
        catch exp %#ok<NASGU>


            entryToRemove(i)=true;

            data(i).Name='';
            data(i).Source='';
            data(i).SourceType='';
            data(i).Users={};
            data(i).Class='';
            data(i).Category='o';
        end

        if~isempty(evalutedObject)
            data(i).Name=var.Name;
            data(i).Source=var.Source;
            data(i).SourceType=var.SourceType;


            data(i).Users=loc_getUSerSIDs(var.Users);

            data(i).Class=class(evalutedObject);

            if isa(evalutedObject,'Simulink.Parameter')||...
                isa(evalutedObject,'Simulink.Variant')||...
                isenum(evalutedObject)||...
                any(strcmp(data(i).Class,validParamClasses))





                data(i).Category='p';

            elseif isa(evalutedObject,'Simulink.Signal')


                data(i).Category='s';

            elseif isa(evalutedObject,'Simulink.Bus')||...
                isa(evalutedObject,'Simulink.NumericType')||...
                isa(evalutedObject,'Simulink.AliasType')

                data(i).Category='d';
            else

                data(i).Category='o';
            end
        end
    end


    data=data(~entryToRemove);

end


function sids=loc_getUSerSIDs(userPaths)
    sids=cell(size(userPaths));
    for n=1:length(userPaths)
        sids{n}=Simulink.ID.getSID(userPaths{n});
    end
end
