function cvds=getAll(this,mode)





    this.load();

    if nargin<2
        mode=[];
    end


    mode=cv.internal.cvdatagroup.checkSimulationMode(mode,[class(this),'.getAll'],2);


    if~isempty(mode)

        cvds=this.m_data.values();

        if mode~=SlCov.CovMode.Mixed

            cvds(cellfun(@(x)x.simMode~=mode,cvds))=[];
        end

    else

        names=this.allNames();
        cvds=cell(size(names));
        for ii=1:numel(names)
            cvds{ii}=this.get(names{ii});
        end
    end

    cvds=cvds(:);


