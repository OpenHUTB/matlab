



function hash=getMD5hash(name)
    md=CGXE.Utils.md5(name);
    hash=sprintf('%08X%08X%08X%08X',md(1),md(2),md(3),md(4));
end