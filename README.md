## 整体设计思路
方块自动下降 > 从键盘读取相关指令 > 根据指令作出相应的动作 > 自动消除并增加计分
## 指令解释
- read in silent mode and read only one characters of input.
```read -s -n 1 command```
- echo without a newline
```echo -n```