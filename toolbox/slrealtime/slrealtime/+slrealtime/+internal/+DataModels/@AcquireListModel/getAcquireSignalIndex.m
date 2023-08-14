function output=getAcquireSignalIndex(this,signalStruct,count,uuid)





    if nargin<3,count='first';end
    if nargin<4,uuid=[];end

    switch count
    case 'first'
        agi=-1;
        si=-1;

        for ag=1:this.nAcquireGroups
            AcquireGroup=this.AcquireGroups(ag);
            if(AcquireGroup.decimation~=signalStruct.decimation)
                continue
            end
            si=AcquireGroup.getAcquireGroupSignalIndex(signalStruct,'first',uuid);
            if si~=-1
                agi=ag;
                output=struct('acquiregroupindex',double(agi),'signalindex',double(si));
                return
            end
        end
    case 'all'
        nfound=0;
        agi=[];
        si=[];
        for ag=1:double(this.nAcquireGroups)
            AcquireGroup=this.AcquireGroups(ag);
            if(signalStruct.decimation~=-2)
                if(AcquireGroup.decimation~=signalStruct.decimation)
                    continue
                end
            end
            tsi=AcquireGroup.getAcquireGroupSignalIndex(signalStruct,'all',uuid);
            if tsi~=-1
                agi=[agi;ag*ones(size(tsi))];%#ok
                si=[si;tsi];%#ok
                nfound=nfound+length(tsi);
            end
        end
        if nfound==0
            agi=-1;
            si=-1;
        end
    otherwise
        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
    end

    output=struct('acquiregroupindex',double(agi),'signalindex',double(si));

end
