function fName=gr_getFileName(this,dlgH,varargin)






    imgFormat=this.ImageFormat;
    if strcmp(imgFormat,'auto')
        adRG=rptgen.appdata_rg;
        if strncmpi(adRG.RootComponent.Format,'pdf',3)
            imgFormat='bmp';
        else
            imgFormat='png';
        end
    end

    rgAd=rptgen.appdata_rg;
    imFile=rgAd.getImgName(imgFormat,'dadlg');


    oldUnits=get(0,'units');
    set(0,'units','pixels');
    screenSize=get(0,'screensize');
    set(0,'units',oldUnits);


    qtDlgPos=get(dlgH,'position');



    if((qtDlgPos(1)<0)||((qtDlgPos(1)+qtDlgPos(3))>screenSize(3)))
        set(dlgH,'position',[0,qtDlgPos(2),qtDlgPos(3),qtDlgPos(4)]);
        qtDlgPos=get(dlgH,'position');
    end
    if((qtDlgPos(2)<0)||((qtDlgPos(2)+qtDlgPos(4))>screenSize(4)))
        set(dlgH,'position',[qtDlgPos(1),0,qtDlgPos(3),qtDlgPos(4)]);
        qtDlgPos=get(dlgH,'position');
    end

    try


        show(dlgH);
        pause(this.TimeDelay);

        jRobot=java.awt.Robot;
        winRect=java.awt.Rectangle(qtDlgPos(1),qtDlgPos(2),qtDlgPos(3),qtDlgPos(4));
        jImgBuff=jRobot.createScreenCapture(winRect);

        jImgFile=java.io.File(imFile.fullname);
        javax.imageio.ImageIO.write(jImgBuff,imgFormat,jImgFile);
        fName=imFile.relname;
    catch ex
        this.status(getString(message('rptgen:RptDialogSnapshot:CaptureError')),2);
        this.status(ex.message,5);
        fName='';
    end
