##特性
	F5 运行
	F6 停止
	F7 编译
	F8 打开taglist 等
	错误信息输出在vim窗口
	代码补全
	代码提示 *编辑模式下 F1
	Alt-F1 查询光标处help.chm
	ahk Snippet补全
	ahk taglist

##To do
	<del>当脚本运行时信息窗口提示Running</del>
	解决中文和特殊字符脚本无法运行
	同时编辑多个脚本时F5 F6混乱
	替换文件管理器为NERDTree
	运行和停止统一为F5
	代码提示做成弹出菜单的形式
	增加Debug功能

##安装
###1.建议路径是 d:\Vim\
	即 d:\
		|-vim\
		|	|-vim73\
		|	|-vimfile\
		|	|-BackupDir\
		|	|-Dict\

###2.配置ctags
如果**不**使用taglist可以省略以下
	ctags.cnf 放到$HOME中,win7默认为 c:\Users\用户名\ ,可以在vim中 :ec $HOME  获取路径   
	ctags.exe 放到环境变量的path中 比如c:\windows   

###3编辑vimrc
	编辑vimrc,根据实际情况配置，路径中尽量不要使用空格和中文
	62行
		let g:AhkSIDE_AhkChm = 'd:\AutoHotKeyL\AutoHotkey.chm'
	63行
		let g:AhkSIDE_AhkExe = 'd:\AutoHotKeyL\AutoHotkeyA32.exe'
	316行
		let Tlist_Ctags_Cmd = 'D:\Vim\vim73\ctags.exe'

  完成后即可

###预设快捷键
	F1 编辑状态下  代码提示
		alt-F1 查询帮助chm
	F2 隐藏显示菜单栏
	F4 跳转到错误
	F5 运行
	F6 结束运行
	F7 编译
	F8 打开taglis等
	F9 生成tags

###其他快捷键
	leader设置为","
	,c 关闭当前窗口
	,o 关闭其他窗口
	,b 新建窗口
	,n 下个窗口

	gc 关闭当前tab
	go 关闭其他tab
	gb 新建tab
	gn 下个tab

	,e 编辑vimrc
	,s 重载vimrc
	,ww 保存文件
	,wf 强制保存
	,qq 退出/关闭窗口
	,qa 退出所有

###再其他的快捷键见vimrc
---

##感谢
感谢[Sunwind](http://blog.csdn.net/liuyukuan) 和 [Array](https://github.com/linxinhong) 的指点 
还有AhkSIDE作者[Loaxs](http://ahk.5d6d.net/viewthread.php?tid=5462&pid=33912&page=1&extra=#pid33912)   
有幸如果作者能看见一定要联系我likaci(a)qq.com   
最主要的功能全部有AhkSIDE实现,我只是稍作修改后各个插件的堆砌，修改后的ahkside在bundle\AhkSIDE\ 中   
还有vim作者,各位插件作者  
##预览
![](http://blog.xiazhiri.com/pic/vim2ahk.jpg)
---
##[更多信息](http://blog.xiazhiri.com/vim2ahk.html)
