function printdatatype(this,sysname,pstruct,thirdpname)







    maxLen=max(max([pstruct.NameLen]),length(thirdpname.blk))+3;
    strFormat=['%2s%-',num2str(maxLen),'s%-21s%s'];

    sysname=strrep(sysname,char(10),char(32));
    str=['### Printing data type report for ',sysname,char(10),char(10)];


    header={thirdpname.blk,'Simulink Data Type',thirdpname.dt};
    dash={repmat('-',1,length(thirdpname.blk)),'------------------',...
    repmat('-',1,length(thirdpname.dt))};
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
