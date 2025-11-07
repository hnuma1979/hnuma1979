# 概要

Ubuntu Serverは、**Canonical社が開発・提供しているLinuxディストリビューション「Ubuntu」のサーバー向けバージョン**です。デスクトップ版とは異なり、GUI（グラフィカルユーザーインターフェース）が標準では含まれておらず、**軽量で安定性・セキュリティに優れたサーバー運用に特化**しています。

### 主な特徴

1. **無料で利用可能**
   - Ubuntu Serverはオープンソースで、商用・非商用問わず無料で使用できます。

2. **豊富なパッケージとサポート**
   - Webサーバー（Apache, Nginx）、データベース（MySQL, PostgreSQL）、メールサーバー、ファイルサーバーなど、さまざまな用途に対応するパッケージが利用可能です。

3. **セキュリティとアップデート**
   - Canonicalが提供するセキュリティアップデートが定期的に配信され、LTS（Long Term Support）版では最大5年間のサポートが受けられます。

4. **クラウド・仮想化に強い**
   - AWS、Azure、Google Cloudなどのクラウド環境に最適化されており、DockerやKubernetesなどのコンテナ技術との相性も良好です。

5. **軽量で高速**
   - GUIがないため、リソース消費が少なく、サーバーとしてのパフォーマンスが高いです。

### よく使われる用途

- Webサーバー（WordPressなどのCMSのホスティング）
- データベースサーバー
- メールサーバー
- VPNサーバー
- ファイル共有（SambaやFTP）
- ゲームサーバー（Minecraftなど）
- 開発・テスト環境（CI/CDパイプライン）

### インストールと管理

- インストールはISOイメージを使って行い、基本的にはコマンドラインで操作します。
- SSHでリモート管理が可能。
- `apt`コマンドでパッケージ管理ができ、設定ファイルは主に`/etc`ディレクトリにあります。

---

Anser by Microsoft 365 Copilot

# ダウンロード

## official valut
* [official](https://releases.ubuntu.com/releases/)

アーカイブ
* [official](https://old-releases.ubuntu.com/releases/)

## mirror
最新版以外は取得不能
* [jaist](http://ftp.jaist.ac.jp/pub/Linux/ubuntu-releases/)
* [riken](https://ftp.riken.jp/Linux/ubuntu-releases/)


