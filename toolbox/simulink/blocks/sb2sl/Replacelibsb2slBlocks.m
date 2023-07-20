function Replacelibsb2slBlocks(block,h)





    LibBlk=get_param(block,'ReferenceBlock');

    switch(LibBlk)
    case 'libsb2sl/LOG/NOT'
        ReplaceLOGNOT(block,h);

    case 'libsb2sl/LOG/EQV'
        ReplaceLOGEQV(block,h);

    case 'libsb2sl/LOG/NEQV'
        ReplaceLOGNEQV(block,h);

    case 'libsb2sl/LOG/Switch'
        ReplaceLOGSwitch(block,h);

    otherwise

        disp('No replacements');
    end


    function ReplaceLOGNOT(block,h)


        if askToReplace(h,block)
            funcSet=uReplaceBlock(h,block,'built-in/Logic',...
            'logicop','NOT');
            msg1=DAStudio.message('sb2sl_blks:libsb2slUpdate:RecActLOG','NOT');
            msg2=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGUpdateReason');
            msg3=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGBlocksBehavior');
            msg=[msg1,' ',msg2,' ',msg3];
            appendTransaction(h,block,msg,{funcSet});
        end

        function ReplaceLOGEQV(block,h)


            if askToReplace(h,block)
                funcSet=uReplaceBlock(h,block,'built-in/Logic',...
                'logicop','NXOR');
                msg1=DAStudio.message('sb2sl_blks:libsb2slUpdate:RecActLOG','NXOR');
                msg2=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGUpdateReason');
                msg3=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGBlocksBehavior');
                msg=[msg1,' ',msg2,' ',msg3];
                appendTransaction(h,block,msg,{funcSet});
            end

            function ReplaceLOGNEQV(block,h)


                if askToReplace(h,block)
                    funcSet=uReplaceBlock(h,block,'built-in/Logic',...
                    'logicop','XOR');
                    msg1=DAStudio.message('sb2sl_blks:libsb2slUpdate:RecActLOG','XOR');
                    msg2=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGUpdateReason');
                    msg3=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGBlocksBehavior');
                    msg=[msg1,' ',msg2,' ',msg3];
                    appendTransaction(h,block,msg,{funcSet});
                end

                function ReplaceLOGSwitch(block,h)


                    if askToReplace(h,block)
                        funcSet=uReplaceBlock(h,block,'built-in/Switch');
                        msg1=DAStudio.message('sb2sl_blks:libsb2slUpdate:RecActLOGSwitch');
                        msg2=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGUpdateReason');
                        msg3=DAStudio.message('sb2sl_blks:libsb2slUpdate:LOGBlocksBehavior');
                        msg=[msg1,' ',msg2,' ',msg3];
                        appendTransaction(h,block,msg,{funcSet});

                        if(doUpdate(h))

                            switchHandle=get_param(block,'Handle');
                            switchName=handleSpecialChars(get_param(switchHandle,'Name'));
                            ParentName=get_param(switchHandle,'Parent');
                            lineHandles=get_param(switchHandle,'LineHandles');

                            InportHandles=[lineHandles.Inport(1);lineHandles.Inport(2)];

                            srcPortHandles=get_param(InportHandles,'SrcPortHandle');
                            srcPortNumber=get_param(cell2mat(srcPortHandles),'Portnumber');
                            srcBlockHandles=get_param(InportHandles,'SrcBlockHandle');
                            srcBlockNames=handleSpecialChars(get_param(cell2mat(srcBlockHandles),'Name'));


                            delete_line(InportHandles);
                            oport=cellfun(@(x,y)[x,'/',num2str(y)],srcBlockNames,srcPortNumber,'UniformOutput',false);
                            iport2=[switchName,'/2'];
                            iport1=[switchName,'/1'];
                            iport={iport2;iport1};
                            add_line({ParentName;ParentName},oport,iport,'Autorouting','on');
                        end
                    end

                    function ostr=handleSpecialChars(istr)
                        ostr=strrep(istr,'/','//');
