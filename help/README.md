
# 文档翻译
## 环境配置

1. 下载并安装[Page Edit](https://sigil-ebook.com/pageedit/download/) 。

2. 打开需要翻译的文档，将原英文文档复制一份，并在原来的文件名后增加`_zh_CN`（_ZhongHua_ChiNa），比如将`matlab\help\driving\ug\select-waypoints-for-3d-simulation.html`复制并重命名为`matlab\help\driving\ug\select-waypoints-for-3d-simulation_zh_CN.html`，进行内容的翻译（使用浏览器查看内容）。
<img src=fig/page_edit.png alt="保存页面" width="780" />

3. 将翻译的文档拷贝到自己`matlab/help`对应目录中。

4. 最终使用`matlab`的文档查看命令进行翻译文档的校对。例如：
```matlab
doc('select-waypoints-for-3d-simulation') 
```

<img src=fig/help_view.png alt="保存页面" width="780" />



## 其他文档翻译
翻译`matlab`不自带的文档，包括[`Raodrunner`](https://ww2.mathworks.cn/help/roadrunner/index.html) 和[`Roadrunner Scenario`](https://ww2.mathworks.cn/help/roadrunner-scenario/index.html) 工具箱的文档。

