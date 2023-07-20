function getSpecfromSysObj(this,hS,inputnumerictype)






    FilterStructure='CIC Decimator';



    [ipsize,ipbp]=hdlfilter.getSizesfromNumericType(inputnumerictype);
    inputformat=[ipsize,ipbp];
    NumberOfSections=hS.NumSections;
    DifferentialDelay=hS.DifferentialDelay;
    DecimationFactor=hS.DecimationFactor;

    this.set('NumberOfSections',NumberOfSections,...
    'DifferentialDelay',DifferentialDelay,...
    'DecimationFactor',DecimationFactor,...
    'FilterStructure',FilterStructure);


    updateInputInfo(this,inputformat);


    updateSectionsInfo(this,hS,inputformat);


    updateOutputInfo(this,hS,inputformat);

    function updateInputInfo(this,inputformat)


        this.inputsltype=hdlgetsltypefromsizes(inputformat(1),inputformat(2),true);



        function this=updateSectionsInfo(this,hS,inputformat)

            switch hS.FixedPointDataType
            case{'Full precision','Minimum section word lengths','Specify word lengths'}
                [ssizes,sbps]=getWLFL(this,hS,inputformat);
            case 'Specify word and fraction lengths'
                ssizes=hS.SectionWordLengths;
                if size(ssizes,2)==1

                    ssizes=ssizes*ones(1,2*this.NumberOfSections);
                end
                sbps=hS.SectionFractionLengths;
                numbp=size(sbps,2);
                reqdnumbp=2*this.NumberOfSections;

                if numbp<reqdnumbp

                    numzeros=reqdnumbp-numbp;
                    sbps=[sbps,zeros(1,numzeros)];
                end
            otherwise
                error(message('HDLShared:hdlfilter:wrongfixedpointmode',hS.FixedPointDataType));
            end
            sltypes=cell(1,length(ssizes));
            for n=1:length(ssizes)
                nsltype=hdlgetsltypefromsizes(ssizes(n),sbps(n),true);
                sltypes{n}=nsltype;
            end
            this.SectionSLtypes=sltypes;



            function[ssizes,sbps,outwl,outfl]=getWLFL(this,hS,inputformat)



                switch hS.FixedPointDataType
                case 'Full precision'
                    outwl=0;
                    swl=0;
                    modestr='fullprecision';
                case 'Minimum section word lengths'
                    outwl=hS.OutputWordLength;
                    swl=0;
                    modestr='minwordlengths';
                case 'Specify word lengths'
                    modestr='specifywordlengths';
                    outwl=hS.OutputWordLength;
                    swl=hS.SectionWordLengths;
                    if length(swl)==1
                        swl=swl*ones(1,2*this.numberofsections);
                    end
                end
                [ssizes,sbps,outwl,outfl]=filterdesign.internal.cicdecimwlnfl(inputformat(1),inputformat(2),...
                modestr,this.NumberOfSections,this.DecimationFactor,...
                this.DifferentialDelay,outwl,swl);


                function this=updateOutputInfo(this,hS,inputformat)



                    switch hS.FixedPointDataType
                    case{'Full precision','Minimum section word lengths','Specify word lengths'}
                        [~,~,outsize,outbp]=getWLFL(this,hS,inputformat);
                    case 'Specify word and fraction lengths'
                        outsize=hS.OutputWordLength;
                        outbp=hS.OutputFractionLength;
                    otherwise
                        error(message('HDLShared:hdlfilter:wrongfixedpointmode',hS.FixedPointDataType));
                    end

                    this.outputsltype=hdlgetsltypefromsizes(outsize,outbp,true);
