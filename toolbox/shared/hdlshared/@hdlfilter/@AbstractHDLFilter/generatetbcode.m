function generatetbcode(this,filterobj,varargin)






    if hdlgetparameter('gen_eda_scripts')
        hdlsetparameter('hdlcompilescript',true);
        hdlsetparameter('hdlcompiletb',true);
        hdlsetparameter('hdlsimscript',true);
        hdlsetparameter('hdlsimprojectscript',false);
        hdlsetparameter('hdlsynthscript',false);
        hdlsetparameter('hdlmapfile',false);
    else
        hdlsetparameter('hdlcompilescript',false);
        hdlsetparameter('hdlcompiletb',false);
        hdlsetparameter('hdlsimscript',false);
        hdlsetparameter('hdlsimprojectscript',false);
        hdlsetparameter('hdlsynthscript',false);
        hdlsetparameter('hdlmapfile',false);
    end



    if localIsnewTBStyleSupported(filterobj)



        inputdata=maketbstimulus(this,filterobj,varargin{:});

        localgentb(this,filterobj,inputdata);
    else
        if strcmpi(hdlgetparameter('target_language'),'VHDL')
            generatevhdltb(filterobj,varargin{:});
        else
            generateverilogtb(filterobj,varargin{:});
        end
        hdlwritescripts;
    end










    function localgentb(this,filterobj,inputdata)

        tbtype=hdlgetparameter('target_language');
        fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:tbgenstart',...
        upper(tbtype))));


        this.setimplementation;
        this.createtbportlist;

        oldcastbeforesum=this.overrideCastbeforeSum(filterobj);
        [hTb,indata,outdata]=this.createHDLTestbench(filterobj,inputdata);

        this.overrideCastbeforeSum(filterobj,oldcastbeforesum);

        TestbenchFiles=hTb.makehdltb(indata,outdata);
        fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:tbgendone',...
        upper(tbtype))));

        tbref=hdlgetparameter('tbrefsignals');
        hdlsetparameter('tbrefsignals',1);
        localhdlwritescripts(TestbenchFiles);
        hdlsetparameter('tbrefsignals',tbref);


        function localhdlwritescripts(testbenchfiles)

            if hdlgetparameter('gen_eda_scripts')
                hdlsetparameter('hdlcompilescript',true);
                hdlsetparameter('hdlcompiletb',true);
                hdlsetparameter('hdlsimscript',true);
                hdlsetparameter('hdlsimprojectscript',false);
                hdlsetparameter('hdlsynthscript',false);
                hdlsetparameter('hdlmapfile',false);

            else

                hdlsetparameter('hdlcompilescript',false);
                hdlsetparameter('hdlcompiletb',false);
                hdlsetparameter('hdlsimscript',false);
                hdlsetparameter('hdlsimprojectscript',false);
                hdlsetparameter('hdlsynthscript',false);
                hdlsetparameter('hdlmapfile',false);
            end

            hE=filterhdlcoder.EDAScripts(testbenchfiles);
            hE.writeAllScripts;




            function success=ismultirate(filterobj)
                success=...
                isa(filterobj,'dsp.internal.mfilt.linearinterp')||...
                isa(filterobj,'dsp.internal.mfilt.holdinterp')||...
                isa(filterobj,'dsp.internal.mfilt.cicinterp')||...
                isa(filterobj,'dsp.internal.mfilt.firinterp')||...
                isa(filterobj,'mfilt.firdecim')||...
                isa(filterobj,'mfilt.cicdecim')||...
                isa(filterobj,'mfilt.firtdecim');

                function success=localIsnewTBStyleSupported(filterobj)



                    success=~(...
                    (hdlgetparameter('clockinputs')==2&&ismultirate(filterobj)));


