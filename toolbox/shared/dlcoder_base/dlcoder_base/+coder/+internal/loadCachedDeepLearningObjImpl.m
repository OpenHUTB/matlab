function[matObj,variableName]=loadCachedDeepLearningObjImpl(matfile,variableName)






    coder.internal.assert((coder.internal.isCharOrScalarString(matfile)),...
    'gpucoder:cnncodegen:invalid_filename',...
    matfile);

    if endsWith(matfile,'.mat')


        coder.internal.assert((coder.internal.isConst(matfile)&&...
        coder.const(exist(matfile,'file'))),...
        'gpucoder:cnncodegen:invalid_matfile',...
        matfile);


        if isempty(variableName)

            matobjStruct=load(matfile);
            f=fields(matobjStruct);
            foundDLObject=false;


            for i=1:length(f)


                if coder.internal.isSupportedDLModel(matobjStruct.(f{i}))
                    if~foundDLObject
                        matObj=matobjStruct.(f{i});


                        variableName=f{i};
                        foundDLObject=true;
                    else




                        error(message('gpucoder:cnncodegen:invalidDLObjectCount'));
                    end
                end
            end

            coder.internal.assert(foundDLObject,'gpucoder:cnncodegen:invalid_matfile_object',matfile);
        else

            matObjStruct=load(matfile,variableName);


            matObj=matObjStruct.(variableName);


            coder.internal.assert(coder.internal.isSupportedDLModel(matObj),...
            'gpucoder:cnncodegen:invalid_matfile_object',...
            matfile);

        end
    else
        ss=regexp(matfile,'(.*)\((.*)\)','tokens');
        if~isempty(ss)
            ss=ss{:};
            matfile=ss{1};
            if~isempty(ss{2})
                matObj=eval(['feval(''',matfile,''',',ss{2},')']);
                return;
            end
        end


        coder.internal.assert(coder.internal.isConst(matfile)&&...
        exist(matfile,'file')==2,...
        'gpucoder:cnncodegen:invalid_filename',matfile);

        matObj=feval(matfile);
        coder.internal.assert(coder.internal.isSupportedDLModel(matObj),...
        'gpucoder:cnncodegen:invalid_function',...
        matfile);
    end

end
