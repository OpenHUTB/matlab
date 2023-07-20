function[bool]=isBusSignal(aVar,varargin)











    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=false;


    if isempty(varargin)
        ALLOW_TT=true;
    else
        ALLOW_TT=varargin{1};
    end


    if~isstruct(aVar)
        bool=false;
        return;
    end


    if isGroundSignal(aVar)||(isstruct(aVar)&&isempty(fieldnames(aVar)))
        bool=true;
        return;
    end

    N=numel(aVar);


    for j=1:N

        structFields=fieldnames(aVar(j));


        for k=1:length(structFields)


            if isa(aVar(j).(structFields{k}),'struct')


                bool=isBusSignal(aVar(j).(structFields{k}),ALLOW_TT);


            elseif Simulink.sdi.internal.Util.isMATLABTimeseries(aVar(j).(structFields{k}))

                tsDataVals=aVar(j).(structFields{k}).Data;

                if isempty(tsDataVals)||isempty(aVar(j).(structFields{k}).Time)...
                    ||isstruct(tsDataVals)
                    return
                else
                    bool=true;
                end


            elseif isGroundSignal(aVar(j).(structFields{k}))

                bool=true;
            elseif isSLTimeTable(aVar(j).(structFields{k}))&&ALLOW_TT
                bool=true;
            else

                bool=false;
            end


            if~bool
                return;
            end

        end
    end

end

