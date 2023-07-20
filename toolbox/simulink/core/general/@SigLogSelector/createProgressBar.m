function pb=createProgressBar(title)



    pb=DAStudio.WaitBar;
    pb.setWindowTitle(title);
    pb.setCircularProgressBar(true);
    pb.show();
end
