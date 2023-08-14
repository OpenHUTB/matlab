function modes=allSimulationModes(this,name)




    modes=[];

    if nargin>1
        name=convertStringsToChars(name);
        validateattributes(name,{'char'},{'nonempty','vector','nrows',1},2);
    end


    names=this.m_data.keys();

    if nargin<2

        modes=cellfun(@(key)uint32(this.m_data(key).simMode),names);
    else

        uname=SlCov.CoverageAPI.removeVersionMangle(name);
        uname=regexprep(uname,'\s+\([a-zA-Z]\w+\)$','');

        if numel(name)~=numel(uname)

            if this.m_data.isKey(name)
                modes=this.m_data(name).simMode;
            end
        else
            unames=SlCov.CoverageAPI.removeVersionMangle(names);
            unames=regexprep(unames,'\s+\([a-zA-Z]\w+\)$','');
            allData=this.m_data.values();
            modes=arrayfun(@(idx)uint32(allData{idx}.simMode),find(strcmp(uname,unames)),'UniformOutput',false);
            modes=[modes{:}];
        end
    end



    if isempty(modes)
        modes={};
    else
        modes=SlCov.CovMode.toString(unique(modes(:)));
        if~iscell(modes)
            modes={modes};
        end
    end


