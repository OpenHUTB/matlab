function v=validateImplParams(this,hC)




    v=baseValidateImplParams(this,hC);


    genericsListStr=this.getImplParams('GenericList');
    if~isempty(genericsListStr)
        formatStr='The parameter input should be in the format of {{''GenericName'', ''GenericValue'', ''GenericType''}}.';


        try
            genericsList=getGenericsInfo(this);
        catch ME
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InvalidGenericList',genericsListStr,formatStr,ME.message));
            return;
        end


        if~iscell(genericsList)
            v(end+1)=hdlvalidatestruct(1,...
            sprintf('GenericList parameter input "%s" is not a cell array. %s',...
            genericsListStr,formatStr),...
            'hdlcoder:validate:InvalidGenericList');
            return;
        end

        for ii=1:length(genericsList)
            genericInfo=genericsList{ii};


            if~iscell(genericInfo)
                v(end+1)=hdlvalidatestruct(1,...
                sprintf('Each entry in GenericList parameter "%s" should be a cell array. %s',...
                genericsListStr,formatStr),...
                'hdlcoder:validate:InvalidGenericList');%#ok<*AGROW>
                return;
            end


            if isempty(genericInfo)
                continue;
            end


            if length(genericInfo)<2
                v(end+1)=hdlvalidatestruct(1,...
                sprintf('Each entry in GenericList parameter "%s" should be a cell array containing at least two strings ''GenericName'' and ''GenericValue''. %s',...
                genericsListStr,formatStr),...
                'hdlcoder:validate:InvalidGenericList');
                return;
            end


            genericName=genericInfo{1};
            genericValue=genericInfo{2};
            if length(genericInfo)>2
                genericType=genericInfo{3};
            else
                genericType='integer';
            end
            if~ischar(genericName)||~ischar(genericValue)||~ischar(genericType)
                v(end+1)=hdlvalidatestruct(1,...
                sprintf('Each entry in GenericList parameter "%s" should be a cell array containing at least two strings ''GenericName'' and ''GenericValue''. %s',...
                genericsListStr,formatStr),...
                'hdlcoder:validate:InvalidGenericList');
                return;
            end
        end
    end