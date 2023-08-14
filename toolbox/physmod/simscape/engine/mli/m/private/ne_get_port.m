function portlabel=ne_get_port(mlidPath)
    rev=mlidPath(end:-1:1);
    [~,rest]=strtok(rev,'.');
    portlabel=strtok(rest,'.');
    portlabel=portlabel(end:-1:1);
