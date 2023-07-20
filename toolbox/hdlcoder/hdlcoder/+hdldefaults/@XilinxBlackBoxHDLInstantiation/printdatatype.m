function printdatatype(this,sysname,pstruct)







    maxLen=max([pstruct.NameLen])+3;
    maxLen=max(maxLen,16);
    strFormat=['%2s%-',num2str(maxLen),'s%-21s%s'];

    sysname=strrep(sysname,char(10),char(32));
    str=['### Printing data type report for ',sysname,char(10),char(10)];


    header={'Gateway Block','Simulink Data Type','Xilinx Data Type'};
    dash={'-------------','------------------','----------------'};
    str=[str,sprintf(strFormat,'',header{1},header{2},header{3}),char(10)];
    str=[str,sprintf(strFormat,'',dash{1},dash{2},dash{3}),char(10)];


    for n=1:length(pstruct)

        pstruct(n).Name=strrep(pstruct(n).Name,char(10),char(32));
        str=[str,sprintf(strFormat,'',pstruct(n).Name,pstruct(n).SType,...
        pstruct(n).XType),char(10)];

    end

    str=strrep(str,'%','%%');
    str=strrep(str,'\','\\');

    fprintf([char(10),str,char(10)]);
