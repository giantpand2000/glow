#!/bin/bash
# 文件名：remove_load_call.sh
set -x
# 定义文件
LOG_FILE="src/load_err.log"
CODE_FILE="src/load_all_fn.rs"

rustfmt --edition 2021 "$CODE_FILE"

# 提取 log 文件中所有函数符号
# 注意这里假设错误信息中 "symbol glXXX" 格式固定
funcs=$(grep -o 'symbol gl[A-Za-z0-9_]*' "$LOG_FILE" | sed 's/symbol gl//' | sort | uniq)

echo "即将删除以下对应的加载函数调用："
echo "$funcs"

# 遍历每个提取到的函数名，并删除代码文件中对应的行
for func in $funcs; do
    # 构造待删除的函数调用模式
    # 例如：针对 BeginQuery，应删除 "self.BeginQuery_load_with_dyn(get_proc_address);"
    pattern="self\.$func""_load_with_dyn(get_proc_address);"
    echo "删除代码中包含： $pattern"

    # 使用 gsed 删除匹配行（macOS 下建议使用 gsed，如果你在 Linux 可直接用 sed）
    # gsed 的 -i 参数语法和 GNU sed 一致
    gsed -i "/$pattern/d" "$CODE_FILE"
done

echo "处理完成！"

rustfmt --edition 2021 "$CODE_FILE"

gsed -i '/^[[:space:]]*{}$/d' "$CODE_FILE"

rustfmt --edition 2021 "$CODE_FILE"
