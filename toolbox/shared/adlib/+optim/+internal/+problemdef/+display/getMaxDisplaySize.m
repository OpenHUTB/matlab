function[maxwidth,maxheight]=getMaxDisplaySize









    commandWindowSize=matlab.desktop.commandwindow.size;






    maxwidth=max(0,commandWindowSize(1)-4);




    maxheight=max(1,commandWindowSize(2)-12);



