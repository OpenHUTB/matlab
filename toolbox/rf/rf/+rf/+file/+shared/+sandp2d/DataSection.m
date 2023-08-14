classdef DataSection<rf.file.shared.DataSection




    properties(SetAccess=protected)
IMT
    end

    methods
        function obj=DataSection(newSmallSignal,newNoise,newIMT)
            obj=obj@rf.file.shared.DataSection(newSmallSignal,newNoise);
            obj.IMT=newIMT;
        end
    end

    methods
        function set.IMT(obj,newIMT)
            if~isa(newIMT,obj.getvalidimtclass)||(numel(newIMT)>1)
                error(message('rf:rffile:shared:BadInputArg','IMT',class(obj),obj.getvalidimtclass))
            end
            obj.IMT=newIMT;
        end
    end

    methods
        function out=convertto3ddata(obj)


            ssdata=obj.SmallSignal.Data;
            numfrq=size(ssdata,1);
            firstcols=ssdata(:,2:2:(end-1));
            secondcols=ssdata(:,3:2:end);

            firstcols(:,2)=firstcols(:,3);
            firstcols(:,3)=ssdata(:,4);
            secondcols(:,2)=secondcols(:,3);
            secondcols(:,3)=ssdata(:,5);

            switch obj.SmallSignal.Format
            case 'db'
                out2d=power(10,firstcols/20).*exp(1i*pi*secondcols/180);
            case 'ma'
                out2d=firstcols.*exp(1i*pi*secondcols/180);
            case 'ri'
                out2d=firstcols+1i*secondcols;
            case 'vdb'
                out2d(:,1)=((firstcols(:,1)+1)./(firstcols(:,1)-1)).*exp(1i*pi*secondcols(:,1)/180);
                out2d(:,2)=power(10,firstcols(:,2)/20).*exp(1i*pi*secondcols(:,2)/180);
                out2d(:,3)=power(10,firstcols(:,3)/20).*exp(1i*pi*secondcols(:,3)/180);
                out2d(:,4)=((firstcols(:,4)+1)./(firstcols(:,4)-1)).*exp(1i*pi*secondcols(:,4)/180);
            end
            out=zeros(2,2,numfrq);
            idx=1;
            for rr=1:2
                for cc=1:2
                    out(rr,cc,:)=reshape(out2d(:,idx),1,1,numfrq);
                    idx=idx+1;
                end
            end
        end
    end

    methods(Static,Access=protected,Hidden)
        function validatesmallsignalobj(newSmallSignal)
            validateattributes(newSmallSignal,{'rf.file.shared.sandp2d.SmallSignalData'},{'scalar'},'','SmallSignal')
        end

        function out=getvalidnoiseclass
            out='rf.file.shared.sandp2d.NoiseData';
        end

        function out=getvalidimtclass
            out='rf.file.shared.sandp2d.IMTData';
        end
    end


    methods
        function out=hasimt(obj)
            out=~isempty(obj.IMT);
        end
    end
end