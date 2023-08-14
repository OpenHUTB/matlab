function[names,varargout]=allNames(this,mode)





    narginchk(1,2);
    nargoutchk(0,2);
    this.load();

    if nargin<2
        mode=[];
    end


    mode=cv.internal.cvdatagroup.checkSimulationMode(mode,[class(this),'.allNames'],2);


    names=this.m_data.keys();

    isModeSelection=~isempty(mode);
    if isModeSelection
        if mode==SlCov.CovMode.Mixed
            idx=cellfun(@(key)this.m_data(key).simMode==SlCov.CovMode.Normal,names);
            names(idx)=regexprep(names(idx),'^(.*)$','$1 (Normal)');
        else
            names(cellfun(@(key)this.m_data(key).simMode~=mode,names))=[];
        end
    end


    origNames=names;
    names=SlCov.CoverageAPI.removeVersionMangle(names);


    if~(isModeSelection&&mode==SlCov.CovMode.Mixed)
        names=unique(regexprep(names,'\s+\([a-zA-Z]\w+\)$',''));
    end


    names=unique(names(:));

    if nargout<2
        return
    end


    if isModeSelection
        if mode~=SlCov.CovMode.Mixed
            modes=repmat({{SlCov.CovMode.toString(mode)}},size(names));
        else
            modes=cellfun(@(key){SlCov.CovMode.toString(this.m_data(key).simMode)},origNames,'UniformOutput',false);
            modes=modes(:);
        end
    else
        modes=cellfun(@(key)this.allSimulationModes(key),names,'UniformOutput',false);
    end

    varargout{1}=modes;




