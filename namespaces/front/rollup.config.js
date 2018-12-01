// rollup.config.js

import babel        from 'rollup-plugin-babel'
import nodeResolve  from 'rollup-plugin-node-resolve'
import commonjs     from 'rollup-plugin-commonjs'
import nodeBuiltins from 'rollup-plugin-node-builtins'
import nodeGlobals  from 'rollup-plugin-node-globals'
import vue          from 'rollup-plugin-vue'
import postcssFontAwesome from 'postcss-font-awesome'

const base = {
  plugins: [
    // CommonJSモジュールをES6に変換
    commonjs(),

    nodeGlobals(),

    nodeBuiltins(),

    // npmモジュールを`node_modules`から読み込む
    nodeResolve({ jsnext: true }),

    // .vueのrequire
    vue({
      css: true, // dynamically inject
      postcss: [
        postcssFontAwesome({
          replacement: false
        })
      ],
    }),

    babel({
      exclude: 'node_modules/**',
      runtimeHelpers: true,
      babelrc: false,
      presets: [
        [
          '@babel/env',
          {
            modules: false
          }
        ]
      ],
      "plugins": [
        '@babel/transform-runtime',
        "transform-es2015-destructuring",
      ]
    })
  ],
}

export default [
  Object.assign({}, base, {
    input: 'src/index.js',
    output: {
      file: 'dist/index.js',
      format: 'iife',
      sourcemap: true
    }
  })
]