classdef(CaseInsensitiveProperties,TruncatedProperties)...
    system<rfbbequiv.rfbbequiv





















    properties(Hidden)

        nModels=0;
    end
    methods
        function set.nModels(obj,value)
            if~isequal(obj.nModels,value)

                obj.nModels=setpositive(obj,value,'nModels',...
                true,false,false);
            end
        end
    end

    properties(Hidden)

        TreatSimulinkInputSignalAs='Incident power wave';
    end

    properties

        Models={};
    end
    methods
        function set.Models(obj,value)

            obj.Models=setmodels(obj,value,'Models');
        end
    end

    properties

        ZS=complex(50,0);
    end
    methods
        function set.ZS(obj,value)
            if~isequal(obj.ZS,value)

                obj.ZS=setcomplex(obj,value,'ZS',false);
            end
        end
    end

    properties

        ZL=complex(50,0);
    end
    methods
        function set.ZL(obj,value)
            if~isequal(obj.ZL,value)

                obj.ZL=setcomplex(obj,value,'ZL',false);
            end
        end
    end

    properties(Hidden)

        NoiseResp=0;
    end

    properties(Hidden)

        InputFreq=[];
    end

    properties(Hidden)

        OriginalCkt=[];
    end
    methods
        function set.OriginalCkt(obj,value)

            obj.OriginalCkt=setckt(obj,value,'OriginalCkt');
        end
    end


    methods
        function h=system(varargin)







            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end




            set(h,'Name','rfbbequiv.system object',varargin{:});
        end

    end

    methods
        h=analyze(h,freq)
        h=buildsys(h,originalckts)
        h=destroy(h,destroyData)
        z0=findimpedance(h)
    end

    methods
        function tf=issystemvalid(obj)
            tf=isvalid(obj);
            if tf
                for nn=1:length(obj.Models)
                    tf=tf&&islinearvalid(obj.Models{nn});
                end
            end
        end
    end

end


function out=setckt(h,out,prop_name)
    if isempty(out)
        return
    end
    if(~isa(out,'rfckt.rfckt'))
        error(message('rfblks:rfbbequiv:system:schema:NotACKTObj',...
        h.Name,prop_name));
    end
end


function out=setmodels(h,out,prop_name)
    if isempty(out)
        return
    end

    if~isa(out,'cell')
        error(message('rfblks:rfbbequiv:system:schema:WrongModels',...
        h.Name,prop_name));
    end
    nmodels=length(out);
    for i=1:nmodels
        model=out{i};
        if(~isa(model,'rfbbequiv.linear'))
            error(message('rfblks:rfbbequiv:system:schema:WrongModel',...
            h.Name,prop_name));
        end
    end
end

