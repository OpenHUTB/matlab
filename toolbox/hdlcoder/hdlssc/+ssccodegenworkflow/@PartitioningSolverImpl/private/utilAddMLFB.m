function hMLFB=utilAddMLFB(parent,name,code,position,dataType)





    hMLFB=add_block('hdlsllib/User-Defined Functions/MATLAB Function',strcat(parent,'/',name),...
    'MakeNameUnique','on',...
    'Position',position);
    hmatlabCodeBlk=find(slroot,'-isa','Stateflow.EMChart','Path',getfullname(hMLFB));




    hmatlabCodeBlk.Script=code;





end


