module.exports = {
    "env": {
        "browser": true,
        "es6": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:vue/recommended"
    ],
    "parserOptions": {
        "ecmaVersion": 2017,
        "sourceType": "module"
    },
    "rules": {
        "indent": ["warn", 2],
        "linebreak-style": ["error", "unix"],

        // クオートはシングル。US配列での生産性を重視
        "quotes": ["warn", "single"],

        // consoleに対するwarn。SWでは使えるので問題はないが、なるべくloggerを使うべき
        "no-console": "warn",

        // typoの可能性もあるのでwarn。関数の引数については許容したいのでwarn
        "no-unused-vars": "warn",

        // セミコロン系ルール。
        // できれば書かない & 複数行で結合してしまうケースについてエラー
        "semi": ["warn", "never"],
        "no-unexpected-multiline": "error"
    }
};
