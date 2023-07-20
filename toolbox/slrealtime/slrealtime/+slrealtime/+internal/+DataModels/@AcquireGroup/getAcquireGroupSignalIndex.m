function out_si=getAcquireGroupSignalIndex(this,signalstruct,count,uuid)






    if nargin<3,count='first';end
    if nargin<4,uuid=[];end

    out_si=-1;


    if signalstruct.decimation~=-2&&...
        ~isequal(signalstruct.decimation,this.decimation)
        return;
    end

    xcpsigs=this.xcpSignals.toArray;

    if~isempty(signalstruct.signame)

        si=find(strcmp(signalstruct.signame,{xcpsigs.signalName}));
    else

        si=find(arrayfun(@(x)isequal(signalstruct.blockpath,x.blockPath)&&isequal(signalstruct.portindex,x.portNumber+1),xcpsigs));
    end

    if~isempty(uuid)

        uuid_si=find(arrayfun(@(x)isequal(uuid,x.instrumentUUID),xcpsigs));
        si=intersect(si,uuid_si);
    end

    if~isempty(si)
        switch count
        case 'first'
            out_si=si(1);
        case 'all'
            out_si=si;
        otherwise
            assert(false);
        end
    end
end
