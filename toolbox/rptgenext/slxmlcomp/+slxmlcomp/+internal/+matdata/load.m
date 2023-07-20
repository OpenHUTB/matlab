function refName=load(filePath,variablePath,suffix)









    if nargin<3
        suffix='';
    end

    variable=slxmlcomp.internal.matdata.MatDataCache.get(filePath,variablePath);
    [~,fileName]=fileparts(filePath);



    baseName=matlab.lang.makeValidName([fileName,'_file_contents',suffix]);
    variableName=matlab.lang.makeValidName(variablePath);
    refName=[baseName,'.',variableName];




    if evalin('base',['exist(''',baseName,''')'])
        if evalin('base',['isstruct(',baseName,')'])



            local=evalin('base',baseName);
            fields=fieldnames(local);
            for i=1:numel(fields)


                isopen=comparisons.internal.variableInUse([fileName,'.',fields{i}])||...
                comparisons.internal.variableInUse([baseName,'.',fields{i}]);
                if~isopen

                    local=rmfield(local,fields{i});
                end
            end

            local.(variableName)=variable;
            assignin('base',baseName,local);
            return
        end
    end


    assignin('base',baseName,struct(variableName,variable));
end
