function[A,this]=getData(this,varargin)






    if isempty(this.Data)
        this.Data=localGetData(this);
    end
    A=this.Data;


    function outdata=localGetData(h)



        if isempty(h.Data)&&~isempty(h.Constructor)
            try
                if isSim2FiCall(h)
                    outdata=feval(h.Constructor{:},'robust');
                else
                    outdata=feval(h.Constructor{:});
                end
            catch %#ok<CTCH>


                if length(h.Constructor)>=2
                    outdata=h.Constructor{2};
                    warning(message('Simulink:Timeseries:customConstructor'))
                else
                    error(message('Simulink:Timeseries:invconst'))
                end
            end
        else
            outdata=h.Data;
        end


        function res=isSim2FiCall(h)

            res=(length(h.Constructor)>1)&&strcmpi(h.Constructor{1},'sim2fi');
