function setText(this,text)




    this.Display=sprintf('disp(''%s'');',strrep(text,sprintf('\n'),'\n'));
    this.ShowName=false;
    this.ShowFrame=true;
    this.RequiredFiles={};

end
