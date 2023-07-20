function hdlcode=componentBody(this)





    hdlcode=this.hdlcodeinit;



    dsel=this.findSignalName('dsel','componentBody');
    din1=this.findSignalName('din1','componentBody');
    din2=this.findSignalName('din2','componentBody');
    dout=this.findSignalName('dout','componentBody');

    hdlcode.arch_body_blocks=[...
    ' ',dout,' <= ',din1,' when ',dsel,' = ''0'' else\n',...
    '         ',din2,';\n'];
end

