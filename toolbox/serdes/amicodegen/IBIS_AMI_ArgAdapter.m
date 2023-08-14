

function out=IBIS_AMI_ArgAdapter(in,obj)
    out=regexprep(in,'(\w+)',[obj,'->$1']);
    out=regexprep(out,'&(\w+->\w+)','&($1)');
