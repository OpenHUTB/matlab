function merge(this,other)






    this.defaults=[this.defaults,other.defaults];

    nduplicates=abs(length(unique({this.defaults.BlockType}))-length(this.defaults));


    if~isempty(this.defaults)&&nduplicates>0
        warning(message('hdlcoder:engine:IgnoreDuplicate',num2str(nduplicates)));
    end

    this.statements=[this.statements,other.statements];


    this.settings=[this.settings,other.settings];


    this.HDLTopLevel=other.HDLTopLevel;

