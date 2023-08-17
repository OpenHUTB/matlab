%% 启动后对matlab进行初始化
% 将以下代码放置到startup.m中（位于输入userpath显示的目录）
% 放在matlabroot/tooolbox/local/matlabrc.m中无效（原因未知）
% 
% init_script_path = fullfile('C:', 'workspace', 'utils', 'init_matlab.m');
% if exist(init_script_path, 'file')
%     eval(['cd ' fileparts(init_script_path)]);
%     run(init_script_path);
% end



clear;
% clc;  % 会清除matlab的启动警告
%% 
% 根据MAC地址判断是否是第一次在机器上启动

cur_mac = get_mac();
conf_dir = fullfile(fileparts(matlabroot), 'dong', 'ai', 'conf');
if ~exist(conf_dir, 'dir'); mkdir(conf_dir); end
mac_record_path = fullfile(conf_dir, 'mac.txt');

if ~exist(mac_record_path, 'file')   % 修改mac.txt文件用于调试 init_platform 函数
    % 在新的机器上第一次进行初始化
    init_platform
    writelines(cur_mac, mac_record_path);
else
    mac_record_infos = readlines(mac_record_path);
    history_mac = mac_record_infos{1};
    if strcmp(cur_mac, history_mac) == 0  % 如果MAC地址不同，则表示是在新的机器上运行matlab
        init_platform
        writelines(cur_mac, mac_record_path);
    else
        % 在相同的机器上运行，不需要做第一次初始化的工作
    end
end
%% 
% 全局变量

syn_dir = fileparts(matlabroot);
root_dir = fileparts(syn_dir);
% 数据缓冲目录（可以删除，由BaiduSyncdisk目录下的文件生成），位于BaiduSyncdisk同目录
buf_dir = fullfile(root_dir, 'buffer');
if exist(root_dir, 'dir') && ~exist(buf_dir, 'dir'); mkdir(buf_dir); end

% matlabshared.supportpkg.setSupportPackageRoot(sp_dir);
global local_ssd
local_ssd = 'D:\ssd';  % 存放从matlab ssd目录下载的文件

software_dir = fullfile(matlabroot, 'software');

% RoadRunner 路径
rrAppPath = fullfile(software_dir, 'RoadRunner_2022b', 'bin', 'win64');
rrProjectPath = fullfile(fileparts(matlabroot), 'workspace', 'RoadRunner');

% latex 目录
latex_dir = fullfile(software_dir, 'latex');
% latex_exe_dir = fullfile(latex_dir, 'bin', 'win32'); % latex2016
latex_exe_dir = fullfile(latex_dir, 'bin', 'windows'); % latex 2023

% 工程目录
rep_dir = fullfile(fileparts(matlabroot), 'dong');

% 工作空间（仓库所置的路径）
work_dir = fullfile("C:", "workspace");
if ~exist(work_dir, 'dir'); clear("work_dir"); end

hutb_rep = "https://github.com/OpenHUTB/utils";


%% 
% 后续操作

clear history_mac mac_record_infos
% cd(rep_dir);  % 进入自己的代码仓库

% 进入当前打开文件所在的目录（命令启动报错：输入参数的数目不足）
% tmp = matlab.desktop.editor.getActive;
% if exist(fileparts(tmp.Filename), 'dir')
%     cd(fileparts(tmp.Filename));
% end
%% 
% 设置环境变量

% CUDA_PATH
% NVIDIA_CUDNN
%% 
% 初始化git（在dong/init_rep.m中做了）

% 设置提交信息模板，即修改C:\Users\Administrator\.gitconfig
% git_config_path = fullfile('C:', 'Users', getenv('username'), '.gitconfig');
% type(git_config_path);
% TODO：目录间隔必须是\\
% template_path = fullfile(matlabroot, 'software', 'git', 'etc', 'commit_message.txt'); 
% lines = "[commit]" + newline + "    template=" + template_path;

% writelines(lines, git_config_path, WriteMode="append")
%% 
% 加载自定义快捷键配置方案

% s = settings().matlab.keyboard.delimiter.ShowMatchesOnArrowKey  % delimiter分隔符
%% 支持函数

function init_platform()
% 用户路径（默认Examples放置的路径）
demo_dir = fullfile(fileparts(matlabroot), 'demo');
if exist(demo_dir, 'dir')
    userpath(demo_dir)
end

% 设置和获取自定义支持包根文件夹
% 修改支持包信息
ver_info = get_ver();
sp_dir = fullfile(matlabroot, 'SupportPackages');
writelines(sprintf('(%s)@%s', ver_info, matlabroot), fullfile(sp_dir, 'sppkg_matlab_info.txt'));
matlabshared.supportpkg.setSupportPackageRoot(sp_dir);
% matlabshared.supportpkg.getSupportPackageRoot

% 设置用户路径（Example打开的默认路径）
% userpath(fullfile(matlabroot, 'data'))

correct_vgg

add_path()
end
% 添加path路径


%% 添加工具箱的路径
function add_path()
% work_dir = fullfile('C:', 'workspace');
% if ~exist(work_dir, 'dir')
%     work_dir = fullfile('D:', 'workspace');
% end
% % proj_home_dir = fullfile(work_dir, 'dong');
% 
% addpath(genpath(fullfile(work_dir, 'utils')));  % 添加工具包中的所有路径
% addpath(fullfile(proj_home_dir, 'utils'));
% customPath = fullfile(proj_home_dir, 'utils', 'custom');  % 添加自定义脚本的路径
% addpath(customPath);
% % 添加快捷方式的路径
% addpath(fullfile(proj_home_dir, 'utils', 'shortcut'));

utils_dir = fullfile(matlabroot, 'utils');
if exist(utils_dir, 'dir')
    addpath(genpath(fullfile(utils_dir)));
end

savepath
% 显示当前文件夹以及当前搜索路径中的所有 pathdef.m 文件的路径
% which pathdef.m -all
end


%%
% 得到matlab版本信息
function ver_info = get_ver()
% R2022a
ver_info = version;
ver_pat = "R" + digitsPattern(4) + ("a"|"b");
ver_info = extract(ver_info, ver_pat);
ver_info = ver_info{1};
end
% 得到MAC地址

function cur_mac = get_mac()
[~, mac_res] =  dos('getmac');
mac_pat = alphanumericsPattern(2) + "-" + alphanumericsPattern(2) + "-" + ...
    alphanumericsPattern(2) + "-" + alphanumericsPattern(2) + "-" + ...
    alphanumericsPattern(2) + "-" + alphanumericsPattern(2);
mac_infos = extract(mac_res, mac_pat);
cur_mac = mac_infos{1};
end
% 校正VGG安装信息

function correct_vgg()
% correct vgg16 and vgg19 installation information
vgg16_info_dir = fullfile(matlabshared.supportpkg.getSupportPackageRoot, 'appdata', '3p', 'common', 'vgg16.instrset');
if ~exist(vgg16_info_dir, 'dir'); mkdir(vgg16_info_dir); end
vgg16_mat_dir = fullfile(matlabshared.supportpkg.getSupportPackageRoot, '3P.instrset', 'vgg16.instrset');
vgg16_infos = "installLocation = " + vgg16_mat_dir;
writelines(vgg16_infos, fullfile(vgg16_info_dir, 'vgg16.instrset_install_info.txt'));

vgg19_info_dir = fullfile(matlabshared.supportpkg.getSupportPackageRoot, 'appdata', '3p', 'common', 'vgg19.instrset');
if ~exist(vgg19_info_dir, 'dir'); mkdir(vgg19_info_dir); end
vgg19_mat_dir = fullfile(matlabshared.supportpkg.getSupportPackageRoot, '3P.instrset', 'vgg19.instrset');
vgg19_infos = "installLocation = " + vgg19_mat_dir;
writelines(vgg19_infos, fullfile(vgg19_info_dir,'vgg19.instrset_install_info.txt'));
end
