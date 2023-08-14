function wideBandLineFunction(block)











    setup(block);














    function setup(block)




        block.NumDialogPrms=14;


        CmodYc=block.DialogPrm(1).Data;


        CmodH=block.DialogPrm(2).Data;


        tauj=block.DialogPrm(3).Data;


        epsarr=block.DialogPrm(4).Data;


        alfaYc=block.DialogPrm(5).Data;


        alfaH=block.DialogPrm(6).Data;


        GYc=block.DialogPrm(7).Data;


        GH=block.DialogPrm(8).Data;


        tau=block.DialogPrm(9).Data;


        Ng=block.DialogPrm(10).Data;


        Nc=block.DialogPrm(11).Data;


        NH=block.DialogPrm(12).Data;


        NYc=block.DialogPrm(13).Data;


        dt=block.DialogPrm(14).Data;



        block.NumInputPorts=2;
        block.NumOutputPorts=3;


        block.SetPreCompInpPortInfoToDynamic;
        block.SetPreCompOutPortInfoToDynamic;



        block.InputPort(1).Dimensions=Nc;
        block.InputPort(1).DatatypeID=0;
        block.InputPort(1).Complexity='Real';
        block.InputPort(1).DirectFeedthrough=false;
        block.InputPort(1).SamplingMode=0;


        block.InputPort(2).Dimensions=Nc;
        block.InputPort(2).DatatypeID=0;
        block.InputPort(2).Complexity='Real';
        block.InputPort(2).DirectFeedthrough=false;
        block.InputPort(2).SamplingMode=0;



        block.OutputPort(1).Dimensions=Nc;
        block.OutputPort(1).DatatypeID=0;
        block.OutputPort(1).Complexity='Real';
        block.OutputPort(1).SamplingMode=0;


        block.OutputPort(2).Dimensions=Nc;
        block.OutputPort(2).DatatypeID=0;
        block.OutputPort(2).Complexity='Real';
        block.OutputPort(2).SamplingMode=0;


        block.OutputPort(3).Dimensions=[Nc,Nc];
        block.OutputPort(3).DatatypeID=0;
        block.OutputPort(3).Complexity='Real';
        block.OutputPort(3).SamplingMode=0;


        block.SampleTimes=[dt,0];










        block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
        block.RegBlockMethod('InitializeConditions',@InitializeConditions);
        block.RegBlockMethod('Start',@Start);
        block.RegBlockMethod('Outputs',@Outputs);
        block.RegBlockMethod('Update',@Update);
        block.RegBlockMethod('Derivatives',@Derivatives);






        function DoPostPropSetup(block)
            block.NumDworks=23;


            NYc=block.DialogPrm(13).Data;
            NH=block.DialogPrm(12).Data;
            Nc=block.DialogPrm(11).Data;
            Ng=block.DialogPrm(10).Data;
            tauj=block.DialogPrm(3).Data;


            sX=sum(NH)*Nc;
            sY=Nc*NYc;
            sli=Ng*Nc;
            nn=max(tauj)+1;
            snn=nn*Nc;


            block.Dwork(1).Name='XHk';
            block.Dwork(1).Dimensions=sX;
            block.Dwork(1).DatatypeID=0;
            block.Dwork(1).Complexity='Complex';
            block.Dwork(1).UsedAsDiscState=true;


            block.Dwork(2).Name='XHm';
            block.Dwork(2).Dimensions=sX;
            block.Dwork(2).DatatypeID=0;
            block.Dwork(2).Complexity='Complex';
            block.Dwork(2).UsedAsDiscState=true;


            block.Dwork(3).Name='XYck';
            block.Dwork(3).Dimensions=sY;
            block.Dwork(3).DatatypeID=0;
            block.Dwork(3).Complexity='Complex';
            block.Dwork(3).UsedAsDiscState=true;


            block.Dwork(4).Name='XYcm';
            block.Dwork(4).Dimensions=sY;
            block.Dwork(4).DatatypeID=0;
            block.Dwork(4).Complexity='Complex';
            block.Dwork(4).UsedAsDiscState=true;


            block.Dwork(5).Name='oldinterpk';
            block.Dwork(5).Dimensions=sli;
            block.Dwork(5).DatatypeID=0;
            block.Dwork(5).Complexity='Real';
            block.Dwork(5).UsedAsDiscState=true;


            block.Dwork(6).Name='oldinterpm';
            block.Dwork(6).Dimensions=sli;
            block.Dwork(6).DatatypeID=0;
            block.Dwork(6).Complexity='Real';
            block.Dwork(6).UsedAsDiscState=true;


            block.Dwork(7).Name='interpk';
            block.Dwork(7).Dimensions=sli;
            block.Dwork(7).DatatypeID=0;
            block.Dwork(7).Complexity='Real';
            block.Dwork(7).UsedAsDiscState=true;


            block.Dwork(8).Name='interpm';
            block.Dwork(8).Dimensions=sli;
            block.Dwork(8).DatatypeID=0;
            block.Dwork(8).Complexity='Real';
            block.Dwork(8).UsedAsDiscState=true;


            block.Dwork(9).Name='Ihisk';
            block.Dwork(9).Dimensions=Nc;
            block.Dwork(9).DatatypeID=0;
            block.Dwork(9).Complexity='Real';
            block.Dwork(9).UsedAsDiscState=true;


            block.Dwork(10).Name='Ihism';
            block.Dwork(10).Dimensions=Nc;
            block.Dwork(10).DatatypeID=0;
            block.Dwork(10).Complexity='Real';
            block.Dwork(10).UsedAsDiscState=true;


            block.Dwork(11).Name='oldIhisk';
            block.Dwork(11).Dimensions=Nc;
            block.Dwork(11).DatatypeID=0;
            block.Dwork(11).Complexity='Real';
            block.Dwork(11).UsedAsDiscState=true;


            block.Dwork(12).Name='oldIhism';
            block.Dwork(12).Dimensions=Nc;
            block.Dwork(12).DatatypeID=0;
            block.Dwork(12).Complexity='Real';
            block.Dwork(12).UsedAsDiscState=true;


            block.Dwork(13).Name='Iki';
            block.Dwork(13).Dimensions=Nc;
            block.Dwork(13).DatatypeID=0;
            block.Dwork(13).Complexity='Real';
            block.Dwork(13).UsedAsDiscState=true;


            block.Dwork(14).Name='Imi';
            block.Dwork(14).Dimensions=Nc;
            block.Dwork(14).DatatypeID=0;
            block.Dwork(14).Complexity='Real';
            block.Dwork(14).UsedAsDiscState=true;


            block.Dwork(15).Name='Ik';
            block.Dwork(15).Dimensions=Nc;
            block.Dwork(15).DatatypeID=0;
            block.Dwork(15).Complexity='Real';
            block.Dwork(15).UsedAsDiscState=true;


            block.Dwork(16).Name='Im';
            block.Dwork(16).Dimensions=Nc;
            block.Dwork(16).DatatypeID=0;
            block.Dwork(16).Complexity='Real';
            block.Dwork(16).UsedAsDiscState=true;


            block.Dwork(17).Name='Ikr';
            block.Dwork(17).Dimensions=snn;
            block.Dwork(17).DatatypeID=0;
            block.Dwork(17).Complexity='Real';
            block.Dwork(17).UsedAsDiscState=true;


            block.Dwork(18).Name='Imr';
            block.Dwork(18).Dimensions=snn;
            block.Dwork(18).DatatypeID=0;
            block.Dwork(18).Complexity='Real';
            block.Dwork(18).UsedAsDiscState=true;


            block.Dwork(19).Name='dum_H';
            block.Dwork(19).Dimensions=sX;
            block.Dwork(19).DatatypeID=0;
            block.Dwork(19).Complexity='Complex';
            block.Dwork(19).UsedAsDiscState=true;


            block.Dwork(20).Name='epsarr1';
            block.Dwork(20).Dimensions=sli;
            block.Dwork(20).DatatypeID=0;
            block.Dwork(20).Complexity='Real';
            block.Dwork(20).UsedAsDiscState=true;


            block.Dwork(21).Name='ppek';
            block.Dwork(21).Dimensions=1;
            block.Dwork(21).DatatypeID=0;
            block.Dwork(21).Complexity='Real';
            block.Dwork(21).UsedAsDiscState=true;


            block.Dwork(22).Name='pek2';
            block.Dwork(22).Dimensions=Ng;
            block.Dwork(22).DatatypeID=0;
            block.Dwork(22).Complexity='Real';
            block.Dwork(22).UsedAsDiscState=true;


            block.Dwork(23).Name='pek1';
            block.Dwork(23).Dimensions=Ng;
            block.Dwork(23).DatatypeID=0;
            block.Dwork(23).Complexity='Real';
            block.Dwork(23).UsedAsDiscState=true;





            function InitializeConditions(block)


                tauj=block.DialogPrm(3).Data;

                epsarr=block.DialogPrm(4).Data;

                alfaH=block.DialogPrm(6).Data;

                Ng=block.DialogPrm(10).Data;

                Nc=block.DialogPrm(11).Data;

                NH=block.DialogPrm(12).Data;

                NYc=block.DialogPrm(13).Data;


                sX=sum(NH)*Nc;
                sY=Nc*NYc;
                sli=Ng*Nc;
                nn=max(tauj)+1;
                snn=nn*Nc;


                block.Dwork(1).Data=zeros(sX,1);
                block.Dwork(2).Data=zeros(sX,1);
                block.Dwork(3).Data=zeros(sY,1);
                block.Dwork(4).Data=zeros(sY,1);
                block.Dwork(5).Data=zeros(sli,1);
                block.Dwork(6).Data=zeros(sli,1);
                block.Dwork(7).Data=zeros(sli,1);
                block.Dwork(8).Data=zeros(sli,1);
                block.Dwork(9).Data=zeros(Nc,1);
                block.Dwork(10).Data=zeros(Nc,1);
                block.Dwork(11).Data=zeros(Nc,1);
                block.Dwork(12).Data=zeros(Nc,1);
                block.Dwork(13).Data=zeros(Nc,1);
                block.Dwork(14).Data=zeros(Nc,1);
                block.Dwork(15).Data=zeros(Nc,1);
                block.Dwork(16).Data=zeros(Nc,1);
                block.Dwork(17).Data=zeros(snn,1);
                block.Dwork(18).Data=zeros(snn,1);
                block.Dwork(19).Data=zeros(sX,1);
                block.Dwork(20).Data=zeros(sli,1);
                block.Dwork(21).Data=0;
                block.Dwork(22).Data=zeros(Ng,1);
                block.Dwork(23).Data=zeros(Ng,1);


                for ii=1:Nc
                    block.Dwork(19).Data(ii*length(alfaH)-(length(alfaH)-1):ii*length(alfaH))=alfaH;
                end


                for ii=1:Ng
                    block.Dwork(20).Data(Nc*ii-(Nc-1):Nc*ii,1)=epsarr(ii);
                end



                function Start(block)



                    function Outputs(block)


                        GYc=block.DialogPrm(7).Data;
                        Nc=block.DialogPrm(11).Data;

                        Ga=zeros(Nc);
                        cont=0;

                        for ii=1:Nc
                            Ga(:,ii)=GYc(cont+1:Nc+cont);
                            cont=cont+Nc;
                        end


                        block.OutputPort(1).Data=block.Dwork(9).Data;


                        block.OutputPort(2).Data=block.Dwork(10).Data;


                        block.OutputPort(3).Data=Ga;





                        function Update(block)


                            CmodYc=block.DialogPrm(1).Data;
                            CmodH=block.DialogPrm(2).Data;
                            tauj=block.DialogPrm(3).Data;
                            alfaYc=block.DialogPrm(5).Data;
                            GYc=block.DialogPrm(7).Data;
                            GH=block.DialogPrm(8).Data;
                            Ng=block.DialogPrm(10).Data;
                            Nc=block.DialogPrm(11).Data;
                            NH=block.DialogPrm(12).Data;
                            NYc=block.DialogPrm(13).Data;


                            block.Dwork(21).Data=block.Dwork(21).Data+1;

                            if block.Dwork(21).Data>(1+max(tauj))
                                block.Dwork(21).Data=1;
                            end

                            block.Dwork(22).Data=block.Dwork(21).Data-tauj+1;
                            if any(block.Dwork(22).Data<=0)
                                dum=find(block.Dwork(22).Data<=0);
                                block.Dwork(22).Data(dum)=block.Dwork(22).Data(dum)+max(tauj)+1;
                            end

                            block.Dwork(23).Data=block.Dwork(22).Data-1;
                            if any(block.Dwork(23).Data<=0)
                                dum=find(block.Dwork(23).Data<=0);
                                block.Dwork(23).Data(dum)=block.Dwork(23).Data(dum)+max(tauj)+1;
                            end


                            block.Dwork(11).Data=block.Dwork(9).Data;
                            block.Dwork(12).Data=block.Dwork(10).Data;


                            for ii=1:Nc
                                block.Dwork(15).Data(ii)=sum(GYc(ii:Nc:Nc*Nc).*block.InputPort(1).Data);
                                block.Dwork(16).Data(ii)=sum(GYc(ii:Nc:Nc*Nc).*block.InputPort(2).Data);
                            end
                            block.Dwork(15).Data=block.Dwork(15).Data-block.Dwork(9).Data;
                            block.Dwork(16).Data=block.Dwork(16).Data-block.Dwork(10).Data;


                            block.Dwork(17).Data(block.Dwork(21).Data*Nc-(Nc-1):block.Dwork(21).Data*Nc)=block.Dwork(15).Data+block.Dwork(13).Data;
                            block.Dwork(18).Data(block.Dwork(21).Data*Nc-(Nc-1):block.Dwork(21).Data*Nc)=block.Dwork(16).Data+block.Dwork(14).Data;



                            for ii=1:Ng
                                block.Dwork(7).Data(Nc*ii-(Nc-1):Nc*ii)=block.Dwork(18).Data(Nc*block.Dwork(22).Data(ii)-(Nc-1):Nc*block.Dwork(22).Data(ii));
                                block.Dwork(8).Data(Nc*ii-(Nc-1):Nc*ii)=block.Dwork(17).Data(Nc*block.Dwork(22).Data(ii)-(Nc-1):Nc*block.Dwork(22).Data(ii));

                                interpk1(Nc*ii-(Nc-1):Nc*ii,1)=block.Dwork(18).Data(Nc*block.Dwork(23).Data(ii)-(Nc-1):Nc*block.Dwork(23).Data(ii));
                                interpm1(Nc*ii-(Nc-1):Nc*ii,1)=block.Dwork(17).Data(Nc*block.Dwork(23).Data(ii)-(Nc-1):Nc*block.Dwork(23).Data(ii));
                            end

                            block.Dwork(7).Data=block.Dwork(7).Data+block.Dwork(20).Data.*(interpk1-block.Dwork(7).Data);
                            block.Dwork(8).Data=block.Dwork(8).Data+block.Dwork(20).Data.*(interpm1-block.Dwork(8).Data);



                            block.Dwork(1).Data=block.Dwork(19).Data.*block.Dwork(1).Data;
                            block.Dwork(2).Data=block.Dwork(19).Data.*block.Dwork(2).Data;

                            dum=zeros(length(block.Dwork(1).Data),1);
                            dum2=dum;

                            cont=0;
                            cont2=0;
                            for ii=1:Nc
                                for jj=1:Ng
                                    dum(1+cont:NH(jj)+cont)=block.Dwork(5).Data(jj*Nc-(Nc-1)+cont2);
                                    dum2(1+cont:NH(jj)+cont)=block.Dwork(6).Data(jj*Nc-(Nc-1)+cont2);

                                    cont=cont+NH(jj);
                                end
                                cont2=cont2+1;
                            end

                            block.Dwork(1).Data=block.Dwork(1).Data+dum;
                            block.Dwork(2).Data=block.Dwork(2).Data+dum2;

                            block.Dwork(5).Data=block.Dwork(7).Data;
                            block.Dwork(6).Data=block.Dwork(8).Data;


                            for ii=1:Nc
                                block.Dwork(13).Data(ii)=sum(GH(ii:Nc:length(GH)).*block.Dwork(7).Data);
                                block.Dwork(14).Data(ii)=sum(GH(ii:Nc:length(GH)).*block.Dwork(8).Data);
                            end

                            cont=0;
                            for ii=1:Nc
                                XHdumk=block.Dwork(1).Data(sum(NH)*ii-(sum(NH)-1):sum(NH)*ii);
                                XHdum=block.Dwork(2).Data(sum(NH)*ii-(sum(NH)-1):sum(NH)*ii);

                                for jj=1:Nc
                                    Cdum=CmodH(jj+cont:Nc*Nc:length(CmodH));

                                    block.Dwork(13).Data(jj)=block.Dwork(13).Data(jj)+sum(real(Cdum.*XHdumk));
                                    block.Dwork(14).Data(jj)=block.Dwork(14).Data(jj)+sum(real(Cdum.*XHdum));

                                end
                                cont=cont+Nc;
                            end


                            block.Dwork(9).Data=2.*block.Dwork(13).Data;
                            block.Dwork(10).Data=2.*block.Dwork(14).Data;

                            for ii=1:Nc
                                block.Dwork(3).Data(ii*NYc-(NYc-1):ii*NYc)=block.Dwork(3).Data(ii*NYc-(NYc-1):ii*NYc).*alfaYc+block.InputPort(1).Data(ii);
                                block.Dwork(4).Data(ii*NYc-(NYc-1):ii*NYc)=block.Dwork(4).Data(ii*NYc-(NYc-1):ii*NYc).*alfaYc+block.InputPort(2).Data(ii);
                            end


                            cont=0;
                            for ii=1:Nc
                                dumk=block.Dwork(3).Data(ii*NYc-(NYc-1):ii*NYc);
                                dum=block.Dwork(4).Data(ii*NYc-(NYc-1):ii*NYc);
                                for jj=1:Nc
                                    block.Dwork(9).Data(jj)=block.Dwork(9).Data(jj)-sum(real(CmodYc(jj+cont:Nc*Nc:length(CmodYc)).*dumk));
                                    block.Dwork(10).Data(jj)=block.Dwork(10).Data(jj)-sum(real(CmodYc(jj+cont:Nc*Nc:length(CmodYc)).*dum));
                                end
                                cont=cont+Nc;
                            end



                            function Derivatives(block)




