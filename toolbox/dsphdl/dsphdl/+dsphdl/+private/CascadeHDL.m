function casfilt=CascadeHDL(obj,varargin)








    w=warning('off','dsp:mfilt:mfilt:Obsolete');
    restoreWarn=onCleanup(@()warning(w));


    casfilt=mfilt.cascade;



    casfilt.removestage(1:2);


    indices=strcmpi(varargin,'inputdatatype');
    pos=1:length(indices);
    pos=pos(indices);
    if isempty(pos)
        error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
    end
    nt=varargin{pos+1};
    if~strcmpi(class(nt),'embedded.numerictype')
        error(message('hdlfilter:privgeneratehdl:incorrectinputdatatype'));
    end



    for ind=1:obj.getNumStages
        if ind==1

            mfiltStage=sysobjHdl(obj.(['Stage',int2str(ind)]),'InputDataType',nt);
        else

            cobj=clone(obj.(['Stage',int2str(ind-1)]));
            release(cobj);
            ipval=getHdlipval(cobj,nt);
            previous_output=step(cobj,ipval);



            nt=numerictype(previous_output);


            mfiltStage=sysobjHdl(obj.(['Stage',int2str(ind)]),'InputDataType',nt);
        end

        casfilt.addstage(mfiltStage);
    end

end

