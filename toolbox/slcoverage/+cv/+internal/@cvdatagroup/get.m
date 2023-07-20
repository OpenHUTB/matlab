function cvd=get(this,name,mode)





    this.load();
    cvd=[];
    if nargin<2
        return
    end

    name=convertStringsToChars(name);


    if endsWith(name,'.m')
        name=name(1:end-2);
    end

    validateattributes(name,{'char'},{'nonempty','vector','nrows',1},2);

    if nargin<3
        mode=[];
    end


    mode=cv.internal.cvdatagroup.checkSimulationMode(mode,[class(this),'.get'],3);

    if~isempty(mode)
        if mode~=SlCov.CovMode.Mixed

            if mode~=SlCov.CovMode.Normal
                name=[name,' (',SlCov.CovMode.toString(mode),')'];
            end
        end
        cvd=getData(this,[],name);
    else
        sizeofName=numel(name);
        if sizeofName~=numel(SlCov.CoverageAPI.removeVersionMangle(name))||...
            sizeofName~=numel(regexprep(name,'\s+\([a-zA-Z0-9]\w+\)$',''))

            name=regexprep(name,' \(Normal\)$','');
            cvd=getData(this,[],name);
        else
            modes=this.allSimulationModes(name);
            for ii=1:numel(modes)
                name2=name;
                if~strcmpi(modes{ii},'Normal')
                    name2=[name2,' (',modes{ii},')'];%#ok<AGROW>
                end
                cvd=getData(this,cvd,name2);
            end
        end
    end

end

function cvd=getData(this,cvd,modelName)
    allCvd=this.m_data.values;
    if isempty(allCvd)
        return;
    end

    dbVersion=allCvd{1}.dbVersion;
    modelName=[modelName,'@',dbVersion];

    if this.m_data.isKey(modelName)
        cvd=[cvd;this.m_data(modelName)];
    end
end


